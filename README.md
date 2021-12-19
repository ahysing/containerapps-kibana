## Provision

```bash
az deployment sub create -c --location northeurope  --template-file base.bicep --parameters kubeEnvironment=test storageContainerName=dapr
```
