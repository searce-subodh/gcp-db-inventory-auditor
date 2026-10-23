import json
import argparse
import datetime
import sys
from openpyxl import Workbook
from openpyxl.styles import Font

from googleapiclient import discovery
from googleapiclient.errors import HttpError
import google.auth

def get_active_projects(crm_service):
    """Fetches all active projects accessible by the authenticated credentials."""
    print("Discovering all active projects you have access to...")
    projects = []
    query = "state:ACTIVE"
    
    try:
        request = crm_service.projects().search(query=query)
        while request is not None:
            response = request.execute()
            for project in response.get('projects', []):
                projects.append(project.get('projectId'))
            request = crm_service.projects().search_next(previous_request=request, previous_response=response)
        return projects
    except HttpError as e:
        print(f"Error fetching projects: {e}")
        sys.exit(1)

def list_alloydb_clusters(alloydb_service, project_id):
    """Lists all AlloyDB clusters in a project across all regions."""
    clusters = []
    parent = f"projects/{project_id}/locations/-"
    
    try:
        request = alloydb_service.projects().locations().clusters().list(parent=parent)
        while request is not None:
            response = request.execute()
            if 'clusters' in response:
                clusters.extend(response['clusters'])
            request = alloydb_service.projects().locations().clusters().list_next(previous_request=request, previous_response=response)
        return clusters
    except HttpError as e:
        if e.resp.status in [403, 404]:
            pass 
        else:
            print(f"API Error checking project {project_id} (Clusters): {e._get_reason()}")
        return []

def list_alloydb_instances(alloydb_service, cluster_name):
    """Lists all AlloyDB instances within a specific cluster."""
    instances = []
    try:
        request = alloydb_service.projects().locations().clusters().instances().list(parent=cluster_name)
        while request is not None:
            response = request.execute()
            if 'instances' in response:
                instances.extend(response['instances'])
            request = alloydb_service.projects().locations().clusters().instances().list_next(previous_request=request, previous_response=response)
        return instances
    except HttpError as e:
        print(f"API Error checking cluster {cluster_name} (Instances): {e._get_reason()}")
        return []

def write_to_excel(final_output, file_path):
    """Writes the parsed dictionary to a single Excel sheet."""
    wb = Workbook()
    ws = wb.create_sheet(title="AlloyDB Inventory")
    if "Sheet" in wb.sheetnames:
        del wb["Sheet"]

    headers_written = False

    for instance_data in final_output:
        headers = []
        values = []

        for key, value in instance_data.items():
            headers.append(key)
            if isinstance(value, list):
                clean_value = "\n".join([str(i) for i in value])
                values.append(clean_value)
            elif isinstance(value, dict):
                clean_value = "\n".join([f"{k}: {v}" for k, v in value.items()])
                values.append(clean_value)
            else:
                values.append(value)

        if not headers_written:
            ws.append(headers)
            header_font = Font(bold=True)
            for cell in ws[1]:
                cell.font = header_font
            headers_written = True

        ws.append(values)

    wb.save(file_path)

def helper_function(data, path):
    """Traverses the dictionary based on the dot-notation path, handling lists elegantly."""
    keys = path.split('.')
    current = data
    
    for idx, key in enumerate(keys):
        if isinstance(current, dict):
            current = current.get(key, "N/A")
        elif isinstance(current, list):
            # If we hit a list (like 'nodes'), iterate through it and extract the rest of the path
            remaining_path = '.'.join(keys[idx:])
            extracted_list = []
            for item in current:
                val = helper_function(item, remaining_path)
                if val != "N/A":
                    extracted_list.append(val)
            return extracted_list if extracted_list else "N/A"
        else:
            return "N/A"
    return current

def get_nested_value(data, path):
    if isinstance(path, dict):
        return {label: helper_function(data, api_config) for label, api_config in path.items()}
    return helper_function(data, path)

def arrange_data_based_on_json_file(combined_data, template_file):
    """Arranges data based on mapping file."""
    with open(template_file, 'r') as f:
        template = json.load(f)

    final_report = {}
    
    for label, api_config_path in template.items():
        final_report[label] = get_nested_value(combined_data, api_config_path)

    return final_report

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AlloyDB Inventory Fetching Script")
    parser.add_argument("--filename_prefix", type=str, required=True, help="Prefix for the output Excel filename")
    parser.add_argument("--mapping_file", type=str, required=False, default="alloydb_config.json", help="Path to the mapping JSON template")
    args = parser.parse_args()

    try:
        credentials, default_project = google.auth.default()
        crm_service = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
        # Using alloydb v1 API
        alloydb_service = discovery.build('alloydb', 'v1', credentials=credentials)
    except Exception as e:
        print(f"Authentication failed: {e}")
        print("Run 'gcloud auth application-default login' first.")
        sys.exit(1)

    final_output = []
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    filename = f"{args.filename_prefix}_{timestamp}.xlsx"

    projects = get_active_projects(crm_service)
    print(f"Found {len(projects)} active projects. Scanning for AlloyDB clusters...")

    for project_id in projects:
        clusters = list_alloydb_clusters(alloydb_service, project_id)
        if clusters:
            print(f"Found {len(clusters)} AlloyDB cluster(s) in project: {project_id}")
            
            for cluster in clusters:
                cluster_name_full = cluster.get("name", "")
                cluster_short = cluster_name_full.split('/')[-1] if '/' in cluster_name_full else cluster_name_full
                
                # Fetch instances for this cluster
                instances = list_alloydb_instances(alloydb_service, cluster_name_full)
                
                for instance in instances:
                    instance_name_full = instance.get("name", "")
                    instance_short = instance_name_full.split('/')[-1] if '/' in instance_name_full else instance_name_full
                    
                    # Combine project, cluster, and instance details into a single flattened object
                    combined_data = {
                        "project_id": project_id,
                        "cluster_short_name": cluster_short,
                        "instance_short_name": instance_short,
                        "cluster": cluster,
                        "instance": instance
                    }
                    
                    arranged_data = arrange_data_based_on_json_file(combined_data, args.mapping_file)
                    final_output.append(arranged_data)

    if final_output:
        write_to_excel(final_output, filename)
        print(f"\nReport successfully written to: {filename}")
    else:
        print("\nNo AlloyDB instances found across any scanned projects. File creation skipped.")