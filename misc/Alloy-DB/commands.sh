0. Command : gcloud alloydb clusters list 
NAME: projects/playground-poc-510005/locations/us-central1/clusters/dummy-alloy-cluster
NETWORK: projects/156321610908/global/networks/default
STATUS: READY



1. Command : gcloud alloydb clusters describe dummy-alloy-cluster --region="us-central1"
automatedBackupPolicy:
  backupWindow: 3600s
  enabled: false
  location: us-central1
  timeBasedRetention:
    retentionPeriod: 1209600s
  weeklySchedule:
    daysOfWeek:
    - MONDAY
    - TUESDAY
    - WEDNESDAY
    - THURSDAY
    - FRIDAY
    - SATURDAY
    - SUNDAY
    startTimes:
    - hours: 23
clusterType: PRIMARY
continuousBackupConfig:
  enabled: true
  recoveryWindowDays: 14
continuousBackupInfo:
  enabledTime: '2026-10-23T10:51:47.419386960Z'
  encryptionInfo:
    encryptionType: GOOGLE_DEFAULT_ENCRYPTION
  schedule:
  - MONDAY
  - TUESDAY
  - WEDNESDAY
  - THURSDAY
  - FRIDAY
  - SATURDAY
  - SUNDAY
createTime: '2026-10-23T10:51:47.609256403Z'
databaseVersion: POSTGRES_18
dataplexConfig:
  enabled: true
encryptionInfo:
  encryptionType: GOOGLE_DEFAULT_ENCRYPTION
name: projects/playground-poc-510005/locations/us-central1/clusters/dummy-alloy-cluster
network: projects/156321610908/global/networks/default
networkConfig:
  network: projects/156321610908/global/networks/default
reconciling: false
state: READY
subscriptionType: STANDARD
uid: 37262ee4-5ad5-4c5d-9bf7-1e4888abb0fc
updateTime: '2026-10-23T10:57:56.531739326Z'

2. 
Command : gcloud alloydb instances list --cluster="dummy-alloy-cluster" --region="us-central1"
NAME: projects/playground-poc-510005/locations/us-central1/clusters/dummy-alloy-cluster/instances/dummy-alloy-instance
INSTANCE_TYPE: PRIMARY
STATUS: READY

3. 
Command : gcloud alloydb instances describe dummy-alloy-instance --cluster="dummy-alloy-cluster" --region="us-central1"activationPolicy: ALWAYS
availabilityType: REGIONAL
clientConnectionConfig:
  sslConfig:
    sslMode: ENCRYPTED_ONLY
createTime: '2026-10-23T10:51:54.745446509Z'
instanceType: PRIMARY
ipAddress: 172.31.82.4
machineConfig:
  cpuCount: 2
maintenanceVersionName: POSTGRES_18.20260902.01_15
name: projects/playground-poc-510005/locations/us-central1/clusters/dummy-alloy-cluster/instances/dummy-alloy-instance
nodes:
- isHotStandby: true
  zoneId: us-central1-f
observabilityConfig:
  enabled: false
  maxQueryStringLength: 10240
  preserveComments: false
  queryPlansPerMinute: 20
  recordApplicationTags: false
  trackActiveQueries: false
  trackWaitEventTypes: true
  trackWaitEvents: true
observabilityInstanceInfo:
  maxQueryStringLength: 10240
  queryPlansPerMinute: 20
  trackWaitEventTypes: true
  trackWaitEvents: true
queryInsightsConfig:
  queryPlansPerMinute: 5
  queryStringLength: 1024
  recordApplicationTags: false
  recordClientAddress: false
queryInsightsInfo:
  enabled: true
  queryPlansPerMinute: 5
  queryStringLength: 1024
reconciling: false
state: READY
uid: 6d345948-42fc-4207-9d70-528fbf11321f
updateTime: '2026-10-23T11:00:27.911329749Z'
writableNode:
  zoneId: us-central1-b

