# Hosting Elasticsearch with Kibana

[Azure Container Apps](https://azure.microsoft.com/en-us/services/container-apps/) is a software as a service offering from Microsoft for hosting and connecting collections of applications running as containers. It has is fully managed which takes the burden of managing a kubernetes cluster off your back. No more cluster upgrades are required 🙌.

This is a working example of [elasticsearch](https://www.elastic.co/elasticsearch/) running with a [kibana](https://www.elastic.co/kibana/) front end on **Azure Container Apps**. Elasticsearch is running in a single node configuration.

## Disclaimer

This is a demonstration only, and should not be used in any serious context without modifications. The drawbacks of this configuration are

* The trail license is default for kibana. You get no customer support with this license
* No mounted volumes. All data in elasticsearch is stored inside the docker container

## Provision

First enable container apps as seen on [Quickstart: Deploy your first container app](https://docs.microsoft.com/EN-US/azure/container-apps/get-started?tabs=bash)

```bash
az extension add --name containerapp
az provider register --namespace Microsoft.App
```

```bash
az login
az account set -s <your subscription name>
az deployment sub create -c --location northeurope  --template-file base.bicep --parameters kubeEnvironment=test
```

## Reading System logs

Open log analytics and perform

```text
ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('elasticsearch', 'kibana') and ContainerName_s <> 'daprd' | project Log_s, TimeGenerated, ContainerAppName_s, ContainerName_s | order by TimeGenerated desc
```
