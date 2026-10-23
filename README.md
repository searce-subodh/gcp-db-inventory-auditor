# GCP Database Inventory Auditor

A unified command-line tool for discovering, extracting, and reporting configuration metadata across Google Cloud Platform database and caching services. The tool accepts multi-level scope definitions (Organizations, Folders, and Projects) via YAML, deduplicates redundant resource hierarchies, and exports per-service inventory reports into individual sheets of an Excel workbook.

---

## Supported Services

* **Google Cloud SQL** (MySQL, Postgres, SQL Server)
* **Memorystore for Redis**
* **Memorystore for Memcached**
* **Memorystore for Valkey** (via REST API authentication)
* **AlloyDB for PostgreSQL** (Cluster and Instance topology)
* **Cloud Spanner** (Instances and metadata)
* **BigQuery** (Datasets and access metadata)

---

## Usage

Run the scanner by pointing it to your scope file and configuration mapping:

```bash
python unified_db_inventory.py \
  --config_file scope.yaml \
  --mapping_file combined_config.json \
  --filename_prefix gcp_db_inventory
```

### CLI Arguments

| Argument | Required | Default | Description |
| :--- | :---: | :---: | :--- |
| `--config_file` | **Yes** | — | Path to the YAML file defining scanned organizations, folders, or projects. |
| `--mapping_file` | No | `combined_config.json` | Path to the unified JSON schema template. |
| `--filename_prefix` | No | `gcp_db_inventory` | Prefix used for naming the timestamped Excel report output. |

---

## Output Structure

The generated Excel workbook (`<prefix>_<timestamp>.xlsx`) isolates each resource type into dedicated sheets:

* **`cloudsql`**: Instance specifications, high-availability status, compute/memory specs, IP configs, and backup settings.
* **`redis`**: Cache tier, memory capacity, authorized networks, replication configurations, and engine versions.
* **`valkey`**: Memorystore Valkey instances, shard counts, replica counts, encryption, and persistence modes.
* **`memcached`**: Node counts, allocated memory per node, zone distributions, and endpoints.
* **`alloydb`**: Joined parent cluster metadata with child instance specs, SSL modes, and machine configs.
* **`spanner`**: Processing units, node topologies, and configurations.
* **`bigquery`**: Dataset locations, retention rules, object summaries, and assigned dataset owners.
