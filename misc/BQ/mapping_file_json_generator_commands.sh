
bq --format=prettyjson ls inventory_demo_dataset
bq --format=prettyjson ls --routines inventory_demo_dataset
bq --format=prettyjson ls --models inventory_demo_dataset

bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.ext_us_states
bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.mv_store_summary
bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.sales_data
bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.sales_data_snapshot
bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.vw_recent_sales

bq --format=prettyjson show --routine inventory_demo_dataset.multiply_by_two
bq --format=prettyjson show --routine inventory_demo_dataset.poc_procedure
bq --format=prettyjson show --routine inventory_demo_dataset.sp_archive_old_data
bq --format=prettyjson show --routine inventory_demo_dataset.udf_calculate_tax
bq --format=prettyjson show --model inventory_demo_dataset.poc_kmeans_model


# COMMAND OUTPUT

 Command :bq --format=prettyjson ls inventory_demo_dataset
[
  {
    "creationTime": "1792615853504",
    "id": "playground-poc-510005:inventory_demo_dataset.ext_us_states",
    "kind": "bigquery#table",
    "tableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "ext_us_states"
    },
    "type": "EXTERNAL"
  },
  {
    "creationTime": "1792614695103",
    "id": "playground-poc-510005:inventory_demo_dataset.mv_store_summary",
    "kind": "bigquery#table",
    "tableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "mv_store_summary"
    },
    "type": "MATERIALIZED_VIEW"
  },
  {
    "clustering": {
      "fields": [
        "store_id"
      ]
    },
    "creationTime": "1792614694015",
    "id": "playground-poc-510005:inventory_demo_dataset.sales_data",
    "kind": "bigquery#table",
    "labels": {
      "domain": "sales",
      "env": "dev"
    },
    "tableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "sales_data"
    },
    "timePartitioning": {
      "field": "transaction_date",
      "type": "DAY"
    },
    "type": "TABLE"
  },
  {
    "clustering": {
      "fields": [
        "store_id"
      ]
    },
    "creationTime": "1792615854212",
    "expirationTime": "1792702254029",
    "id": "playground-poc-510005:inventory_demo_dataset.sales_data_snapshot",
    "kind": "bigquery#table",
    "labels": {
      "domain": "sales",
      "env": "dev"
    },
    "tableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "sales_data_snapshot"
    },
    "timePartitioning": {
      "field": "transaction_date",
      "type": "DAY"
    },
    "type": "SNAPSHOT"
  },
  {
    "creationTime": "1792614694554",
    "id": "playground-poc-510005:inventory_demo_dataset.vw_recent_sales",
    "kind": "bigquery#table",
    "tableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "vw_recent_sales"
    },
    "type": "VIEW",
    "view": {
      "useLegacySql": false
    }
  }
]

 Command :bq --format=prettyjson ls --routines inventory_demo_dataset
[
  {
    "creationTime": "1792615855825",
    "etag": "8XyEqo0N2dneIAAHASYxqQ==",
    "language": "SQL",
    "lastModifiedTime": "1792615855825",
    "routineReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "routineId": "multiply_by_two"
    },
    "routineType": "SCALAR_FUNCTION"
  },
  {
    "creationTime": "1792615855186",
    "etag": "BmQu2Kt2UDNCkAfAwkm4rw==",
    "language": "SQL",
    "lastModifiedTime": "1792615855186",
    "routineReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "routineId": "poc_procedure"
    },
    "routineType": "PROCEDURE"
  },
  {
    "creationTime": "1792614695873",
    "etag": "6s1VH6suzuPpTvGqrmwh5w==",
    "language": "SQL",
    "lastModifiedTime": "1792614695873",
    "routineReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "routineId": "sp_archive_old_data"
    },
    "routineType": "PROCEDURE"
  },
  {
    "creationTime": "1792614696480",
    "etag": "t0aNp5+El54nx+hKQNx5og==",
    "language": "SQL",
    "lastModifiedTime": "1792614696480",
    "routineReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "routineId": "udf_calculate_tax"
    },
    "routineType": "SCALAR_FUNCTION"
  }
]

 Command :bq --format=prettyjson ls --models inventory_demo_dataset
[
  {
    "creationTime": "1792615879723",
    "lastModifiedTime": "1792615879906",
    "modelReference": {
      "datasetId": "inventory_demo_dataset",
      "modelId": "poc_kmeans_model",
      "projectId": "playground-poc-510005"
    },
    "modelType": "KMEANS"
  }
]

 Command :bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.ext_us_states
{
  "creationTime": "1792615853504",
  "etag": "UwQ3il071/HpQHD0VRAd8A==",
  "externalDataConfiguration": {
    "autodetect": true,
    "sourceFormat": "CSV",
    "sourceUris": [
      "gs://cloud-samples-data/bigquery/us-states/us-states.csv"
    ]
  },
  "id": "playground-poc-510005:inventory_demo_dataset.ext_us_states",
  "kind": "bigquery#table",
  "lastModifiedTime": "1792615853504",
  "location": "US",
  "numActiveLogicalBytes": "0",
  "numBytes": "0",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numRows": "0",
  "numTotalLogicalBytes": "0",
  "requirePartitionFilter": false,
  "schema": {
    "fields": [
      {
        "mode": "NULLABLE",
        "name": "string_field_0",
        "type": "STRING"
      },
      {
        "mode": "NULLABLE",
        "name": "string_field_1",
        "type": "STRING"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/playground-poc-510005/datasets/inventory_demo_dataset/tables/ext_us_states",
  "tableReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "tableId": "ext_us_states"
  },
  "type": "EXTERNAL"
}

 Command :bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.mv_store_summary
{
  "creationTime": "1792614695103",
  "description": "Materialized view pre-computing total sales per store",
  "etag": "v74qcVRubthCzImxHzfkEA==",
  "id": "playground-poc-510005:inventory_demo_dataset.mv_store_summary",
  "kind": "bigquery#table",
  "lastModifiedTime": "1792614696687",
  "location": "US",
  "materializedView": {
    "enableRefresh": true,
    "lastRefreshTime": "1792614695577",
    "query": "SELECT store_id, SUM(amount) as total_sales\nFROM inventory_demo_dataset.sales_data\nGROUP BY store_id",
    "refreshIntervalMs": "1800000"
  },
  "materializedViewStatus": {
    "refreshWatermark": "2026-10-21T20:31:35.577Z"
  },
  "numActiveLogicalBytes": "0",
  "numActivePhysicalBytes": "695",
  "numBytes": "0",
  "numCurrentPhysicalBytes": "695",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numLongTermPhysicalBytes": "0",
  "numRows": "0",
  "numTimeTravelPhysicalBytes": "0",
  "numTotalLogicalBytes": "0",
  "numTotalPhysicalBytes": "695",
  "schema": {
    "fields": [
      {
        "name": "store_id",
        "type": "STRING"
      },
      {
        "name": "total_sales",
        "type": "FLOAT"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/playground-poc-510005/datasets/inventory_demo_dataset/tables/mv_store_summary",
  "tableReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "tableId": "mv_store_summary"
  },
  "type": "MATERIALIZED_VIEW"
}

 Command :bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.sales_data
{
  "clustering": {
    "fields": [
      "store_id"
    ]
  },
  "creationTime": "1792614694015",
  "description": "Standard table with daily partitioning and store clustering",
  "etag": "R520TMNPUsNb+otrhXu6HQ==",
  "id": "playground-poc-510005:inventory_demo_dataset.sales_data",
  "kind": "bigquery#table",
  "labels": {
    "domain": "sales",
    "env": "dev"
  },
  "lastModifiedTime": "1792614694015",
  "location": "US",
  "numActiveLogicalBytes": "0",
  "numBytes": "0",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numRows": "0",
  "numTotalLogicalBytes": "0",
  "partitionDefinition": {
    "partitionedColumn": [
      {
        "field": "transaction_date"
      }
    ]
  },
  "schema": {
    "fields": [
      {
        "name": "transaction_id",
        "type": "STRING"
      },
      {
        "name": "transaction_date",
        "type": "DATE"
      },
      {
        "name": "amount",
        "type": "FLOAT"
      },
      {
        "name": "store_id",
        "type": "STRING"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/playground-poc-510005/datasets/inventory_demo_dataset/tables/sales_data",
  "tableReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "tableId": "sales_data"
  },
  "timePartitioning": {
    "field": "transaction_date",
    "type": "DAY"
  },
  "type": "TABLE"
}

 Command :bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.sales_data_snapshot
{
  "clustering": {
    "fields": [
      "store_id"
    ]
  },
  "creationTime": "1792615854212",
  "description": "Standard table with daily partitioning and store clustering",
  "etag": "rcLvORGlLIhtXl/Tj8ejJw==",
  "expirationTime": "1792702254029",
  "id": "playground-poc-510005:inventory_demo_dataset.sales_data_snapshot",
  "kind": "bigquery#table",
  "labels": {
    "domain": "sales",
    "env": "dev"
  },
  "lastModifiedTime": "1792615854212",
  "location": "US",
  "numActiveLogicalBytes": "0",
  "numBytes": "0",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numRows": "0",
  "numTotalLogicalBytes": "0",
  "partitionDefinition": {
    "partitionedColumn": [
      {
        "field": "transaction_date"
      }
    ]
  },
  "schema": {
    "fields": [
      {
        "name": "transaction_id",
        "type": "STRING"
      },
      {
        "name": "transaction_date",
        "type": "DATE"
      },
      {
        "name": "amount",
        "type": "FLOAT"
      },
      {
        "name": "store_id",
        "type": "STRING"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/playground-poc-510005/datasets/inventory_demo_dataset/tables/sales_data_snapshot",
  "snapshotDefinition": {
    "baseTableReference": {
      "datasetId": "inventory_demo_dataset",
      "projectId": "playground-poc-510005",
      "tableId": "sales_data"
    },
    "snapshotTime": "2026-10-21T20:50:54.174Z"
  },
  "tableReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "tableId": "sales_data_snapshot"
  },
  "timePartitioning": {
    "field": "transaction_date",
    "type": "DAY"
  },
  "type": "SNAPSHOT"
}

 Command :bq --format=prettyjson show playground-poc-510005:inventory_demo_dataset.vw_recent_sales
{
  "creationTime": "1792614694554",
  "description": "Logical view filtering the last 7 days of sales",
  "etag": "vwQoJfkmcpZYA5sfbzoJGg==",
  "id": "playground-poc-510005:inventory_demo_dataset.vw_recent_sales",
  "kind": "bigquery#table",
  "lastModifiedTime": "1792614694554",
  "location": "US",
  "numActiveLogicalBytes": "0",
  "numBytes": "0",
  "numLongTermBytes": "0",
  "numLongTermLogicalBytes": "0",
  "numRows": "0",
  "numTotalLogicalBytes": "0",
  "schema": {
    "fields": [
      {
        "name": "transaction_id",
        "type": "STRING"
      },
      {
        "name": "transaction_date",
        "type": "DATE"
      },
      {
        "name": "amount",
        "type": "FLOAT"
      },
      {
        "name": "store_id",
        "type": "STRING"
      }
    ]
  },
  "selfLink": "https://bigquery.googleapis.com/bigquery/v2/projects/playground-poc-510005/datasets/inventory_demo_dataset/tables/vw_recent_sales",
  "tableReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "tableId": "vw_recent_sales"
  },
  "type": "VIEW",
  "view": {
    "query": "SELECT * FROM inventory_demo_dataset.sales_data\nWHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)",
    "useLegacySql": false
  }
}

 Command :bq --format=prettyjson show --routine inventory_demo_dataset.multiply_by_two
{
  "arguments": [
    {
      "dataType": {
        "typeKind": "INT64"
      },
      "name": "x"
    }
  ],
  "creationTime": "1792615855825",
  "definitionBody": "x * 2",
  "etag": "8XyEqo0N2dneIAAHASYxqQ==",
  "language": "SQL",
  "lastModifiedTime": "1792615855825",
  "returnType": {
    "typeKind": "INT64"
  },
  "routineReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "routineId": "multiply_by_two"
  },
  "routineType": "SCALAR_FUNCTION"
}

 Command :bq --format=prettyjson show --routine inventory_demo_dataset.poc_procedure
{
  "creationTime": "1792615855186",
  "definitionBody": "BEGIN\n  -- A simple query to demonstrate procedure execution\n  SELECT COUNT(*) AS total_rows \n  FROM `playground-poc-510005.inventory_demo_dataset.sales_data`;\nEND",
  "etag": "BmQu2Kt2UDNCkAfAwkm4rw==",
  "language": "SQL",
  "lastModifiedTime": "1792615855186",
  "routineReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "routineId": "poc_procedure"
  },
  "routineType": "PROCEDURE"
}

 Command :bq --format=prettyjson show --routine inventory_demo_dataset.sp_archive_old_data
{
  "arguments": [
    {
      "dataType": {
        "typeKind": "DATE"
      },
      "name": "cutoff_date"
    }
  ],
  "creationTime": "1792614695873",
  "definitionBody": "BEGIN\n  -- Dummy logic for demonstration\n  SELECT FORMAT('Archiving data before %t', cutoff_date);\nEND",
  "etag": "6s1VH6suzuPpTvGqrmwh5w==",
  "language": "SQL",
  "lastModifiedTime": "1792614695873",
  "routineReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "routineId": "sp_archive_old_data"
  },
  "routineType": "PROCEDURE"
}

 Command :bq --format=prettyjson show --routine inventory_demo_dataset.udf_calculate_tax
{
  "arguments": [
    {
      "dataType": {
        "typeKind": "FLOAT64"
      },
      "name": "amount"
    }
  ],
  "creationTime": "1792614696480",
  "definitionBody": "amount * 0.08",
  "description": "UDF to calculate flat 8% tax",
  "etag": "t0aNp5+El54nx+hKQNx5og==",
  "language": "SQL",
  "lastModifiedTime": "1792614696480",
  "returnType": {
    "typeKind": "FLOAT64"
  },
  "routineReference": {
    "datasetId": "inventory_demo_dataset",
    "projectId": "playground-poc-510005",
    "routineId": "udf_calculate_tax"
  },
  "routineType": "SCALAR_FUNCTION"
}

 Command :bq --format=prettyjson show --model inventory_demo_dataset.poc_kmeans_model
{
  "creationTime": "1792615879723",
  "etag": "0p4MFwSxa/GkXyI8oQ2Ddw==",
  "featureColumns": [
    {
      "name": "col1",
      "type": {
        "typeKind": "INT64"
      }
    },
    {
      "name": "col2",
      "type": {
        "typeKind": "INT64"
      }
    }
  ],
  "lastModifiedTime": "1792615879906",
  "location": "US",
  "modelReference": {
    "datasetId": "inventory_demo_dataset",
    "modelId": "poc_kmeans_model",
    "projectId": "playground-poc-510005"
  },
  "modelType": "KMEANS",
  "trainingRuns": [
    {
      "evaluationMetrics": {
        "clusteringMetrics": {
          "clusters": [
            {
              "centroidId": "1",
              "count": "2",
              "featureValues": [
                {
                  "featureColumn": "col1",
                  "numericalValue": 1.5000000000000004
                },
                {
                  "featureColumn": "col2",
                  "numericalValue": 2.5000000000000004
                }
              ]
            },
            {
              "centroidId": "2",
              "count": "2",
              "featureValues": [
                {
                  "featureColumn": "col1",
                  "numericalValue": 8.5
                },
                {
                  "featureColumn": "col2",
                  "numericalValue": 9.5
                }
              ]
            }
          ],
          "daviesBouldinIndex": 0.1428571428571429,
          "meanSquaredDistance": 0.030000000000000013
        }
      },
      "results": [
        {
          "clusterInfos": [
            {
              "centroidId": "1",
              "clusterRadius": 0.24494897427831785,
              "clusterSize": "2"
            },
            {
              "centroidId": "2",
              "clusterRadius": 0.24494897427831785,
              "clusterSize": "2"
            }
          ],
          "durationMs": "1646",
          "index": 0,
          "trainingLoss": 0.06000000000000001
        },
        {
          "clusterInfos": [
            {
              "centroidId": "1",
              "clusterRadius": 0.17320508075688776,
              "clusterSize": "2"
            },
            {
              "centroidId": "2",
              "clusterRadius": 0.17320508075688776,
              "clusterSize": "2"
            }
          ],
          "durationMs": "1562",
          "index": 1,
          "trainingLoss": 0.030000000000000013
        },
        {
          "clusterInfos": [
            {
              "centroidId": "1",
              "clusterRadius": 0.17320508075688776,
              "clusterSize": "2"
            },
            {
              "centroidId": "2",
              "clusterRadius": 0.17320508075688776,
              "clusterSize": "2"
            }
          ],
          "durationMs": "1632",
          "index": 2,
          "trainingLoss": 0.030000000000000013
        }
      ],
      "startTime": "2026-10-21T20:50:56.204Z",
      "trainingOptions": {
        "distanceType": "EUCLIDEAN",
        "earlyStop": true,
        "kmeansInitializationMethod": "RANDOM",
        "maxIterations": "20",
        "minRelativeProgress": 0.01,
        "numClusters": "2",
        "standardizeFeatures": true,
        "warmStart": false
      },
      "trainingStartTime": "1792615856204"
    }
  ]
}
