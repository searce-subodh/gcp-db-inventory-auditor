import json
import argparse
import datetime
import sys
import subprocess
from openpyxl import Workbook
from openpyxl.styles import Font

from googleapiclient import discovery
from googleapiclient.errors import HttpError
import google.auth

def get_active_projects(crm_service, org_id):
    """Fetches all active projects under a specific Organization."""
    print(f"Discovering all active projects under Organization ID: {org_id}...")
    projects = []
    # Filter by organization ID and active state
    query = f"parent.id:{org_id} parent.type:organization state:ACTIVE"
    
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

def list_and_describe_valkey_instances(project_id):
    """Lists instances to get names, then runs 'describe' on each Valkey instance."""
    detailed_instances = []
    try:
        # 1. List all instances in the project
        list_result = subprocess.check_output([
            "gcloud", "memorystore", "instances", "list",
            f"--project={project_id}",
            "--location=-",
            "--format=json"
        ], stderr=subprocess.DEVNULL, text=True)
        
        instances = json.loads(list_result)
        
        for inst in instances:
            # Only process Valkey engines
            if "VALKEY" in inst.get("engineVersion", ""):
                instance_name = inst.get("name").split('/')[-1]
                # Extract location from the resource name: projects/../locations/{location}/instances/..
                location = inst.get("name").split('/locations/')[1].split('/')[0]
                
                # 2. Run the describe command explicitly for this instance
                describe_result = subprocess.check_output([
                    "gcloud", "memorystore", "instances", "describe",
                    instance_name,
                    f"--project={project_id}",
                    f"--location={location}",
                    "--format=json"
                ], stderr=subprocess.DEVNULL, text=True)
                
                detailed_instances.append(json.loads(describe_result))
                
        return detailed_instances
    except subprocess.CalledProcessError:
        return []
    except FileNotFoundError:
        print("Error: 'gcloud' CLI is not installed or not found in system PATH.")
        sys.exit(1)

def write_to_excel(final_output, file_path):
    wb = Workbook()
    ws = wb.create_sheet(title="Valkey Inventory")
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
    keys = path.split('.')
    current = data
    
    for idx, key in enumerate(keys):
        if isinstance(current, dict):
            current = current.get(key, "N/A")
        elif isinstance(current, list):
            remaining_path = '.'.join(keys[idx:])
            extracted_list = []
            for item in current:
                val = helper_function(item, remaining_path)
                if val != "N/A":
                    extracted_list.append(val)
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

def arrange_data_based_on_json_file(instance_data, template_file):
    with open(template_file, 'r') as f:
        template = json.load(f)

    final_report = {}
    
    for label, api_config_path in template.items():
        if api_config_path == "project_id":
            continue
        final_report[label] = get_nested_value(instance_data, api_config_path)

    return final_report

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Valkey/Memorystore Inventory Fetching Script")
    parser.add_argument("--filename_prefix", type=str, required=True, help="Prefix for the output Excel filename")
    parser.add_argument("--mapping_file", type=str, required=False, default="valkey_config.json", help="Path to the mapping JSON template")
    parser.add_argument("--org_id", type=str, required=True, help="Google Cloud Organization ID to scan (e.g., 1234567890)")
    args = parser.parse_args()

    try:
        credentials, default_project = google.auth.default()
        crm_service = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
    except Exception as e:
        print(f"Authentication failed: {e}")
        sys.exit(1)

    final_output = []
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    filename = f"{args.filename_prefix}_{timestamp}.xlsx"

    projects = get_active_projects(crm_service, args.org_id)
    print(f"Found {len(projects)} active projects. Scanning for Valkey instances...")

    for project_id in projects:
        valkey_instances = list_and_describe_valkey_instances(project_id)
        
        if valkey_instances:
            print(f"Found {len(valkey_instances)} Valkey instance(s) in project: {project_id}")
            
            for instance in valkey_instances:
                arranged_data = arrange_data_based_on_json_file(instance, args.mapping_file)
                
                final_row = {"Project ID": project_id}
                final_row.update(arranged_data)
                
                final_output.append(final_row)

    if final_output:
        write_to_excel(final_output, filename)
        print(f"\nReport successfully written to: {filename}")
    else:
        print("\nNo Valkey instances found across any scanned projects. File creation skipped.")