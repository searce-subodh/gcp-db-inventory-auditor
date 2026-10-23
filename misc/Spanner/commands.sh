
Command :gcloud spanner instances list

NAME: dummy-poc-instance
DISPLAY_NAME: Dummy PoC Instance
CONFIG: regional-us-central1
NODE_COUNT: 
PROCESSING_UNITS: 100
STATE: READY
INSTANCE_TYPE: PROVISIONED


Command :gcloud spanner instances describe dummy-poc-instance

config: projects/playground-poc-510005/instanceConfigs/regional-us-central1
createTime: '2026-10-22T07:28:46.706647Z'
defaultBackupScheduleType: AUTOMATIC
displayName: Dummy PoC Instance
edition: STANDARD
instanceType: PROVISIONED
name: projects/playground-poc-510005/instances/dummy-poc-instance
processingUnits: 100
replicaComputeCapacity:
- processingUnits: 100
  replicaSelection:
    location: us-central1
resourceLocation: us-central1
state: READY
updateTime: '2026-10-22T07:28:46.706647Z'