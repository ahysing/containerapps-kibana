targetScope = 'subscription'
//
// verify the application with log analytics in
// ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('elasticsearch', 'kibana') | project Log_s, ContainerAppName_s, ContainerName_s, TimeGenerated | order by TimeGenerated desc
//
param kubeEnvironment string = 'test'
param location string = 'northeurope'
param resourceGroupPrefix string = 'nicx'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceGroupPrefix}-${kubeEnvironment}-rg'
  location: location
}

module containerapps './apps.bicep' = {
  name: 'apps'
  scope: rg
  params: {
    location: location
    kubeEnvironment: kubeEnvironment
  }
}
