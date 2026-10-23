import sys
import re
import yaml
import json
import argparse
import datetime
import subprocess
from openpyxl import Workbook
from openpyxl.styles import Font

from google.cloud import resourcemanager_v3
from googleapiclient import discovery
from googleapiclient.errors import HttpError
import google.auth

# ==========================================
# GCP CLIENT INITIALIZATION
# ==========================================
folders_client = resourcemanager_v3.FoldersClient()
projects_client = resourcemanager_v3.ProjectsClient()

# ==========================================
# HIERARCHY TRAVERSAL & ANCESTRY LOGIC
# ==========================================
def get_ancestry(resource_name):
    """Walks up the resource hierarchy to determine parent nodes."""
    ancestors = []
    current = resource_name

    while current:
        if current.startswith("folders/"):
            try:
                folder_info = folders_client.get_folder(name=current)
                parent = folder_info.parent
                ancestors.append(parent)
                current = parent
            except Exception:
                break
        elif current.startswith("projects/"):
            try:
                project_info = projects_client.get_project(name=current)
                parent = project_info.parent
                ancestors.append(parent)
                current = parent
            except Exception:
                break
        else:
            break

    return ancestors

def get_projects_in_parent(parent_resource_name):
    """Recursively walks down organizations and folders to collect all active projects."""
    found_projects = []

    req_projects = resourcemanager_v3.ListProjectsRequest(parent=parent_resource_name)
    try:
        for project in projects_client.list_projects(request=req_projects):
            if project.state == resourcemanager_v3.Project.State.ACTIVE:
                found_projects.append(project.project_id)
    except Exception as e:
        print(f"  [-] Could not list projects under {parent_resource_name}: {e}")

    req_folders = resourcemanager_v3.ListFoldersRequest(parent=parent_resource_name)
    try:
        for folder in folders_client.list_folders(request=req_folders):
            found_projects.extend(get_projects_in_parent(folder.name))
    except Exception as e:
        print(f"  [-] Could not list folders under {parent_resource_name}: {e}")

    return found_projects

def resolve_target_projects(config_yaml_path):
    """Parses scope YAML, prunes redundant scopes via ancestry checks, and resolves active project IDs."""
    try:
        with open(config_yaml_path, "r") as f:
            config = yaml.safe_load(f) or {}
    except FileNotFoundError:
        print(f"[!] Scope YAML file '{config_yaml_path}' not found.")
        sys.exit(1)

    org_ids = [str(o).strip() for o in (config.get("organizations") or []) if str(o).strip()]
    folder_ids = [str(f).strip() for f in (config.get("folders") or []) if str(f).strip()]
    project_ids = [str(p).strip() for p in (config.get("projects") or []) if str(p).strip()]

    if not org_ids and not folder_ids and not project_ids:
        print("[!] Error: Define at least one Organization, Folder, or Project in scope YAML.")
        sys.exit(1)

    covered_parents = set()
    targets_to_scan = []
    direct_projects_to_scan = []

    # 1. Register organizations
    for org_id in org_ids:
        org_name = f"organizations/{org_id}"
        covered_parents.add(org_name)
        targets_to_scan.append(org_name)
        print(f"[+] Added Organization to scope: {org_name}")

    # 2. Register folders (skip if already under an included organization)
    for folder_id in folder_ids:
        folder_name = f"folders/{folder_id}"
        ancestry = get_ancestry(folder_name)
        if any(ancestor in covered_parents for ancestor in ancestry):
            print(f"[-] Skipping Folder '{folder_id}': Redundant (already covered by parent scope).")
        else:
            covered_parents.add(folder_name)
            targets_to_scan.append(folder_name)
            print(f"[+] Added Folder to scope: {folder_name}")

    # 3. Register direct projects (skip if already under a scanned org or folder)
    for project_id in project_ids:
        proj_name = f"projects/{project_id}"
        ancestry = get_ancestry(proj_name)
        if any(ancestor in covered_parents for ancestor in ancestry):
            print(f"[-] Skipping Project '{project_id}': Redundant (already covered by parent scope).")
        else:
            direct_projects_to_scan.append(project_id)
            print(f"[+] Added Direct Project to scope: {project_id}")

    discovered_projects = []
    for target in targets_to_scan:
        print(f"[*] Discovering projects under: {target}...")
        discovered_projects.extend(get_projects_in_parent(target))

    for p_id in direct_projects_to_scan:
        try:
            p_info = projects_client.get_project(name=f"projects/{p_id}")
            if p_info.state == resourcemanager_v3.Project.State.ACTIVE:
                discovered_projects.append(p_info.project_id)
        except Exception as e:
            print(f"[-] Could not access direct project '{p_id}': {e}")

    unique_projects = sorted(list(set(discovered_projects)))
    print(f"\n[+] Total unique active projects to scan: {len(unique_projects)}\n")
    return unique_projects


# ==========================================
# SERVICE EXTRACTION LOGIC
# ==========================================

# 1. Spanner
def list_spanner_instances(spanner_service, project_id):
    instances, parent = [], f"projects/{project_id}"
    try:
        request = spanner_service.projects().instances().list(parent=parent)
        while request is not None:
            response = request.execute()
            if 'instances' in response:
                instances.extend(response['instances'])
            request = spanner_service.projects().instances().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return instances

# 2. Redis
def list_redis_instances(redis_service, project_id):
    instances, parent = [], f"projects/{project_id}/locations/-"
    try:
        request = redis_service.projects().locations().instances().list(parent=parent)
        while request is not None:
            response = request.execute()
            if 'instances' in response:
                instances.extend(response['instances'])
            request = redis_service.projects().locations().instances().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return instances

# 3. Cloud SQL
def list_cloudsql_instances(sql_service, project_id):
    instances = []
    try:
        request = sql_service.instances().list(project=project_id)
        while request is not None:
            response = request.execute()
            if 'items' in response:
                instances.extend(response['items'])
            request = sql_service.instances().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return instances

def enrich_sql_calculations(data):
    calc = {}
    tier = data.get("settings", {}).get("tier", "")
    if tier.startswith("db-custom-"):
        parts = tier.split("-")
        if len(parts) >= 4:
            calc["vcpu"] = parts[2]
            calc["memory_gb"] = str(int(parts[3]) / 1024)
    else:
        calc["vcpu"] = "Tied to Tier"
        calc["memory_gb"] = "Tied to Tier"
    calc["replica_count"] = len(data.get("replicaNames", []))
    calc["replica_names"] = data.get("replicaNames", [])
    data["_calculated"] = calc
    return data

# 4. BigQuery
def get_datasets_for_project(bq_service, project_id):
    datasets_data = []
    try:
        request = bq_service.datasets().list(projectId=project_id)
        while request is not None:
            response = request.execute()
            for ds in response.get('datasets', []):
                dataset_id = ds['datasetReference']['datasetId']
                try:
                    full_dataset = bq_service.datasets().get(projectId=project_id, datasetId=dataset_id).execute()
                    # Owner & counts calculation
                    owners = []
                    for entry in full_dataset.get("access", []):
                        if entry.get("role") == "OWNER":
                            owner = entry.get("userByEmail") or entry.get("specialGroup") or entry.get("groupByEmail")
                            if owner: owners.append(owner)
                    
                    full_dataset['_calculated'] = {
                        "dataset_owners": ", ".join(owners) if owners else "None",
                        "total_object_count": 0, "table_count": 0, "view_count": 0, "routine_count": 0, "model_count": 0
                    }
                    datasets_data.append(full_dataset)
                except HttpError:
                    pass
            request = bq_service.datasets().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return datasets_data

# 5. AlloyDB
def list_alloydb_clusters(alloydb_service, project_id):
    clusters, parent = [], f"projects/{project_id}/locations/-"
    try:
        request = alloydb_service.projects().locations().clusters().list(parent=parent)
        while request is not None:
            response = request.execute()
            if 'clusters' in response:
                clusters.extend(response['clusters'])
            request = alloydb_service.projects().locations().clusters().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return clusters

def list_alloydb_instances(alloydb_service, cluster_name):
    instances = []
    try:
        request = alloydb_service.projects().locations().clusters().instances().list(parent=cluster_name)
        while request is not None:
            response = request.execute()
            if 'instances' in response:
                instances.extend(response['instances'])
            request = alloydb_service.projects().locations().clusters().instances().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return instances

# 6. Memcached
def list_memcached_instances(memcache_service, project_id):
    instances, parent = [], f"projects/{project_id}/locations/-"
    try:
        request = memcache_service.projects().locations().instances().list(parent=parent)
        while request is not None:
            response = request.execute()
            if 'instances' in response:
                instances.extend(response['instances'])
            request = memcache_service.projects().locations().instances().list_next(previous_request=request, previous_response=response)
    except HttpError:
        pass
    return instances

# 7. Valkey (Subprocess REST Call)
def list_valkey_instances(project_id):
    try:
        token = subprocess.check_output(["gcloud", "auth", "print-access-token"], text=True).strip()
        url = f"https://memorystore.googleapis.com/v1/projects/{project_id}/locations/-/instances"
        curl_cmd = ["curl", "-s", "-H", f"Authorization: Bearer {token}", url]
        
        result = subprocess.check_output(curl_cmd, text=True)
        response = json.loads(result)
        
        if 'error' in response:
            return []
            
        all_instances = response.get('instances', [])
        return [inst for inst in all_instances if "VALKEY" in inst.get("engineVersion", "")]
    except Exception:
        return []


# ==========================================
# PARSING & UTILITIES
# ==========================================
def helper_function(data, path):
    keys = path.split('.')
    current = data
    for idx, key in enumerate(keys):
        if isinstance(current, dict):
            current = current.get(key, "N/A")
        elif isinstance(current, list):
            remaining_path = '.'.join(keys[idx:])
            extracted_list = [helper_function(item, remaining_path) for item in current if helper_function(item, remaining_path) != "N/A"]
            return extracted_list if extracted_list else "N/A"
        else:
            return "N/A"
            
    if isinstance(current, str) and "projects/" in current and "locations/" in current:
        if path == "name":
            return current.split('/')[-1]
    return current

def get_nested_value(data, path):
    if isinstance(path, dict):
        return {label: helper_function(data, api_config) for label, api_config in path.items()}
    return helper_function(data, path)

def arrange_data_based_on_json(data, template):
    final_report = {}
    if "name" in data:
        raw_name = data.get("name", "")
        data["_calculated_short_name"] = raw_name.split('/')[-1] if '/' in raw_name else raw_name
    if "kind" in data and data["kind"] == "sql#instance":
        data = enrich_sql_calculations(data)

    for label, api_config_path in template.items():
        if api_config_path == "project_id":
            continue
        if api_config_path == "name" and "_calculated_short_name" in data:
            final_report[label] = data.get("_calculated_short_name", "N/A")
        else:
            final_report[label] = get_nested_value(data, api_config_path)
    return final_report


# ==========================================
# EXCEL EXPORT
# ==========================================
def write_to_excel(service_outputs, file_path):
    wb = Workbook()
    if "Sheet" in wb.sheetnames:
        del wb["Sheet"]

    for sheet_name, data in service_outputs.items():
        if not data:
            continue
        ws = wb.create_sheet(title=sheet_name)
        headers_written = False
        for instance_data in data:
            headers, values = [], []
            for key, value in instance_data.items():
                headers.append(key)
                if isinstance(value, list):
                    values.append("\n".join([str(i) for i in value]))
                elif isinstance(value, dict):
                    values.append("\n".join([f"{k}: {v}" for k, v in value.items()]))
                else:
                    values.append(value)
                    
            if not headers_written:
                ws.append(headers)
                for cell in ws[1]:
                    cell.font = Font(bold=True)
                headers_written = True
            ws.append(values)
            
    if len(wb.sheetnames) == 0:
        wb.create_sheet("No Data")
    wb.save(file_path)


# ==========================================
# MAIN EXECUTION
# ==========================================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Multi-Service GCP DB Inventory Auditor with Dynamic Hierarchy Scope")
    parser.add_argument("--config_file", type=str, required=True, help="Path to input scope YAML file")
    parser.add_argument("--mapping_file", type=str, default="combined_config.json", help="Path to report mapping JSON")
    parser.add_argument("--filename_prefix", type=str, default="gcp_db_inventory", help="Prefix for output Excel filename")
    args = parser.parse_args()

    # Authenticate standard Discovery APIs
    try:
        credentials, _ = google.auth.default()
        redis_service = discovery.build('redis', 'v1', credentials=credentials)
        sql_service = discovery.build('sqladmin', 'v1beta4', credentials=credentials)
        bq_service = discovery.build('bigquery', 'v2', credentials=credentials)
        spanner_service = discovery.build('spanner', 'v1', credentials=credentials)
        alloydb_service = discovery.build('alloydb', 'v1', credentials=credentials)
        memcache_service = discovery.build('memcache', 'v1', credentials=credentials)
    except Exception as e:
        print(f"Authentication failed: {e}")
        sys.exit(1)

    try:
        with open(args.mapping_file, 'r') as f:
            master_template = json.load(f)
    except FileNotFoundError:
        print(f"[!] Error: Mapping file '{args.mapping_file}' not found.")
        sys.exit(1)

    # Individual sheets mapping
    outputs = {
        "redis": [], "cloudsql": [], "bigquery": [], 
        "spanner": [], "alloydb": [], "memcached": [], "valkey": []
    }

    # Resolve scope from YAML using ancestry pruning
    projects = resolve_target_projects(args.config_file)

    for i, project_id in enumerate(projects, 1):
        print(f"[{i}/{len(projects)}] Processing Project: {project_id}")

        # 1. Redis
        for inst in list_redis_instances(redis_service, project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(inst, master_template.get("redis", {})))
            outputs["redis"].append(row)

        # 2. Cloud SQL
        for inst in list_cloudsql_instances(sql_service, project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(inst, master_template.get("cloudsql", {})))
            outputs["cloudsql"].append(row)

        # 3. BigQuery
        for ds in get_datasets_for_project(bq_service, project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(ds, master_template.get("bigquery", {})))
            outputs["bigquery"].append(row)

        # 4. Spanner
        for inst in list_spanner_instances(spanner_service, project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(inst, master_template.get("spanner", {})))
            outputs["spanner"].append(row)

        # 5. AlloyDB
        for cluster in list_alloydb_clusters(alloydb_service, project_id):
            cluster_name = cluster.get("name", "")
            for inst in list_alloydb_instances(alloydb_service, cluster_name):
                row = {"Project ID": project_id}
                # Pass cluster directly to cluster_mappings
                row.update(arrange_data_based_on_json(cluster, master_template.get("alloydb", {}).get("cluster_mappings", {})))
                # Pass instance directly to instance_mappings
                row.update(arrange_data_based_on_json(inst, master_template.get("alloydb", {}).get("instance_mappings", {})))
                outputs["alloydb"].append(row)

        # 6. Memcached
        for inst in list_memcached_instances(memcache_service, project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(inst, master_template.get("memcached", {})))
            outputs["memcached"].append(row)

        # 7. Valkey
        for inst in list_valkey_instances(project_id):
            row = {"Project ID": project_id}
            row.update(arrange_data_based_on_json(inst, master_template.get("valkey", {})))
            outputs["valkey"].append(row)

    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    output_filename = f"{args.filename_prefix}_{timestamp}.xlsx"
    write_to_excel(outputs, output_filename)
    print(f"\n[DONE] Finished scanning {len(projects)} project(s). Report written to: {output_filename}")