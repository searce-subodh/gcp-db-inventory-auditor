GCP Database Inventory AuditorA unified command-line tool for discovering, extracting, and reporting configuration metadata across Google Cloud Platform database and caching services. The tool accepts multi-level scope definitions (Organizations, Folders, and Projects) via YAML, deduplicates redundant resource hierarchies, and exports per-service inventory reports into individual sheets of an Excel workbook.Supported ServicesGoogle Cloud SQL (MySQL, Postgres, SQL Server)Memorystore for RedisMemorystore for MemcachedMemorystore for Valkey (via REST API authentication)AlloyDB for PostgreSQL (Cluster and Instance topology)Cloud Spanner (Instances and metadata)BigQuery (Datasets and access metadata)Key FeaturesDynamic Scope Resolution: Configure top-level Organizations, intermediate Folders, or standalone Project IDs in a single YAML file.Ancestry-Based Deduplication: Evaluates ancestry trees to prevent redundant scanning of projects located under already-scanned folders or organizations.Template-Driven Extraction: JSON mapping paths define the extracted metrics and column headers without modifying core script logic.Multi-Service Excel Export: Generates an .xlsx workbook containing isolated sheets for each database service scanned (cloudsql, redis, alloydb, memcached, valkey, spanner, bigquery).Calculated Metrics: Includes enriched fields such as Cloud SQL vCPU/RAM extraction from tier strings, replica counting, and dataset object counts.PrerequisitesPython 3.9+Google Cloud SDK (gcloud) installed and authenticatedIAM Permissions across the target scope:roles/resourcemanager.organizationViewer or roles/browserroles/cloudsql.viewerroles/redis.viewerroles/memcache.viewerroles/spanner.viewerroles/alloydb.viewerroles/bigquery.metadataViewerMemorystore API viewer permissions for ValkeyInstallationClone the repository:git clone https://github.com/<your-org-or-username>/gcp-db-inventory-auditor.git
cd gcp-db-inventory-auditor
Create a virtual environment:python3 -m venv venv
source venv/bin/activate
Install dependencies:pip install -r requirements.txt
Authenticate Google Cloud credentials:gcloud auth application-default login
gcloud auth login
Configuration1. Define Scope (scope.yaml)Target entire organizations, specific folders, or standalone projects. Ancestry checking skips explicitly defined folders or projects that are already covered by parent scopes:organizations:
  - "352861796798"

folders:
  # - "123456789012"

projects:
  # - "standalone-project-id"
2. Define Attribute Mapping (combined_config.json)The mapping JSON file determines the fields captured from GCP API payloads:{
  "redis": {
    "Instance Name": "name",
    "Tier": "tier",
    "State": "state",
    "Memory (GB)": "memorySizeGb"
  },
  "cloudsql": {
    "Instance Name": "name",
    "Database Version": "databaseInstalledVersion",
    "Machine type": "settings.tier",
    "vCPU": "_calculated.vcpu",
    "Memory (GB)": "_calculated.memory_gb"
  },
  "alloydb": {
    "cluster_mappings": {
      "Cluster Name": "name",
      "Cluster Type": "clusterType"
    },
    "instance_mappings": {
      "Instance Name": "name",
      "Instance Type": "instanceType"
    }
  },
  "memcached": {
    "Instance Name": "name",
    "Node Count": "nodeCount"
  },
  "valkey": {
    "Instance Name": "name",
    "Node Type": "nodeType",
    "Shard Count": "shardCount"
  },
  "spanner": {
    "Instance Name": "name",
    "Node Count": "nodeCount"
  },
  "bigquery": {
    "Dataset ID": "datasetReference.datasetId",
    "Location": "location"
  }
}
UsageRun the scanner by pointing it to your scope file and configuration mapping:python unified_db_inventory.py \
  --config_file scope.yaml \
  --mapping_file combined_config.json \
  --filename_prefix gcp_db_inventory
CLI ArgumentsArgumentRequiredDefaultDescription--config_fileYes—Path to the YAML file defining scanned organizations, folders, or projects.--mapping_fileNocombined_config.jsonPath to the unified JSON schema template.--filename_prefixNogcp_db_inventoryPrefix used for naming the timestamped Excel report output.Output StructureThe generated Excel workbook (<prefix>_<timestamp>.xlsx) isolates each resource type into dedicated sheets:cloudsql: Instance specifications, high-availability status, compute/memory specs, IP configs, and backup settings.redis: Cache tier, memory capacity, authorized networks, replication configurations, and engine versions.valkey: Memorystore Valkey instances, shard counts, replica counts, encryption, and persistence modes.memcached: Node counts, allocated memory per node, zone distributions, and endpoints.alloydb: Joined parent cluster metadata with child instance specs, SSL modes, and machine configs.spanner: Processing units, node topologies, and configurations.bigquery: Dataset locations, retention rules, object summaries, and assigned dataset owners.
