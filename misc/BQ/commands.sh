# 1. Create the Sandbox Dataset
# Run this via the CLI to create the dataset:

bq mk --location=US inventory_demo_dataset

# 2. Generate the BigQuery Objects
# Execute this unified DDL script in the BigQuery UI or via the CLI using bq query --use_legacy_sql=false:

# SQL
# -- 1. Create a Standard Table (with DE-relevant partitioning & clustering)
CREATE TABLE inventory_demo_dataset.sales_data (
  transaction_id STRING,
  transaction_date DATE,
  amount FLOAT64,
  store_id STRING
)
PARTITION BY transaction_date
CLUSTER BY store_id
OPTIONS(
  description="Standard table with daily partitioning and store clustering",
  labels=[("env", "dev"), ("domain", "sales")]
);

# -- 2. Create a Logical View
CREATE VIEW inventory_demo_dataset.vw_recent_sales
OPTIONS(description="Logical view filtering the last 7 days of sales") AS
SELECT * FROM inventory_demo_dataset.sales_data
WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY);

# -- 3. Create a Materialized View
CREATE MATERIALIZED VIEW inventory_demo_dataset.mv_store_summary
OPTIONS(description="Materialized view pre-computing total sales per store") AS
SELECT store_id, SUM(amount) as total_sales
FROM inventory_demo_dataset.sales_data
GROUP BY store_id;

# -- 4. Create a Stored Procedure (Routine)
CREATE PROCEDURE inventory_demo_dataset.sp_archive_old_data(cutoff_date DATE)
BEGIN
  -- Dummy logic for demonstration
  SELECT FORMAT('Archiving data before %t', cutoff_date);
END;

# -- 5. Create a User-Defined Function (Routine)
CREATE FUNCTION inventory_demo_dataset.udf_calculate_tax(amount FLOAT64) 
RETURNS FLOAT64 
OPTIONS(description="UDF to calculate flat 8% tax") AS (
  amount * 0.08
);

# 3. Analyze the Outputs with bq show
# Now you can run bq show (optionally with --format=prettyjson) against each object to see how the metadata structure changes based on the entity type.

# For the Dataset:


bq show --format=prettyjson inventory_demo_dataset
# (Notice the access control lists, defaultTableExpirationMs, and dataset-level labels.)

# For Tables and Views:


# Standard Table (Look for timePartitioning and clustering nodes)
bq show --format=prettyjson inventory_demo_dataset.sales_data

# Logical View (Look for the 'view' node containing the raw SQL query)
bq show --format=prettyjson inventory_demo_dataset.vw_recent_sales

# Materialized View (Look for materializedView node and enableRefresh flags)
bq show --format=prettyjson inventory_demo_dataset.mv_store_summary
# For Routines (Procedures & UDFs):
You must explicitly pass the --routine flag, otherwise BigQuery assumes you are looking for a table.


# Stored Procedure
bq show --routine --format=prettyjson inventory_demo_dataset.sp_archive_old_data

# UDF
bq show --routine --format=prettyjson inventory_demo_dataset.udf_calculate_tax