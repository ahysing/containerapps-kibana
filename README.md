# Hosting Emojivoto
[emojivoto](https://github.com/BuoyantIO/emojivoto) is an application meant for demonstrating [linkerd](https://linkerd.io). This repository demonstrates hosting emojivoto on Azure Container App.

## Provision

```bash
az deployment sub create -c --location northeurope  --template-file base.bicep --parameters kubeEnvironment=test
```

## Reading System logs

Open log analytics and perform

```text
ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('emojivoto-voting', 'emojivoto-web', 'emojivoto-emoji') and ContainerName_s <> 'daprd' | project Log_s, TimeGenerated, ContainerAppName_s, ContainerName_s | order by TimeGenerated desc
```
