# Hosting Elasticsearch with Kibana

[Azure Container Apps](https://azure.microsoft.com/en-us/services/container-apps/) is a software as a service offering from Microsoft for hosting and connecting collections of applications running as containers. It has is fully managed which takes the burden of managing a kubernetes cluster off your back. No more cluster upgrades are required 🙌.

This is a working example of [elasticsearch](https://www.elastic.co/elasticsearch/) running with a [kibana](https://www.elastic.co/kibana/) front end on **Azure Container Apps**. Elasticsearch is running in a single node configuration.

## Disclaimer

This is a demonstration only, and should not be used in any serious context without modifications. The drawbacks of this configuration are

* The trail license is default for kibana. You get no customer support with this license
* No mounted volumes. All data in elasticsearch is stored inside the docker container

## Provision

```bash
az login
az account set -s <your subscription name>
az deployment sub create -c --location northeurope  --template-file base.bicep --parameters kubeEnvironment=test
```

## Updating the Kibana container

Updating the environment variable `setup.publicBaseurl` correctly one would have to update what was just provisioned. On [Configure Kibana](https://www.elastic.co/guide/en/kibana/current/settings.html) we can read

_"The publicly available URL that end-users access Kibana at. Must include the protocol, hostname, port (if different than the defaults for http and https, 80 and 443 respectively), and the server.basePath (if configured). This setting cannot end in a slash (/)."_

This is publicly available URL is not known before we provision because it is set by azure for us. You can find it in the azure portal by looking for _Application URL_. Copy that URL and use it as `kibanaFqdn` when you update kibana as listed below:

```bash
az login
az account set -s <your subscription name>
az deployment sub create -c --location northeurope  --template-file update-base.bicep --parameters kubeEnvironment=test kibanaFqdn="https://kibana.gentlebush-d7dc1f3f.northeurope.azurecontainerapps.io"
```

## Reading System logs

Open log analytics and perform

```text
ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('elasticsearch', 'kibana') and ContainerName_s <> 'daprd' | project Log_s, TimeGenerated, ContainerAppName_s, ContainerName_s | order by TimeGenerated desc
```
