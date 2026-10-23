COMMAND : gcloud memorystore instances list --location="us-central1"
---
authorizationMode: AUTH_DISABLED
automatedBackupConfig:
  automatedBackupMode: DISABLED
createTime: '2026-10-23T10:49:20.565274352Z'
deletionProtectionEnabled: false
effectiveMaintenanceVersion: MEMORYSTORE_20261008_00_00
encryptionInfo:
  encryptionType: GOOGLE_DEFAULT_ENCRYPTION
engineVersion: VALKEY_7_2
mode: CLUSTER
name: projects/playground-poc-510005/locations/us-central1/instances/dummy-valkey
nodeConfig:
  sizeGb: 1.4
nodeType: SHARED_CORE_NANO
persistenceConfig:
  mode: DISABLED
pscAttachmentDetails:
- connectionType: CONNECTION_TYPE_DISCOVERY
  serviceAttachment: projects/710396579403/regions/us-central1/serviceAttachments/gcp-memorystore-auto-fe59a20bc397d796-psc-sa
- serviceAttachment: projects/710396579403/regions/us-central1/serviceAttachments/gcp-memorystore-auto-fe59a20bc397d796-psc-sa-2
replicaCount: 0
satisfiesPzi: true
serverCaMode: SERVER_CA_MODE_UNSPECIFIED
shardCount: 1
state: ACTIVE
transitEncryptionMode: TRANSIT_ENCRYPTION_DISABLED
uid: 62a6f369-1184-4770-bc7e-12c2c67a7bc6
updateTime: '2026-10-23T10:55:24.929580073Z'
zoneDistributionConfig:
  mode: MULTI_ZONE
