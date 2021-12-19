targetScope = 'subscription'
//
// verify the application with log analytics in
// ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('emojivoto-web', 'emojivoto-voting', 'emojivoto-emoji') and ContainerName_s <> 'daprd' | project Log_s, TimeGenerated, ContainerAppName_s, ContainerName_s
//
param kubeEnvironment string = 'test'
param location string = 'northeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'nicx-${kubeEnvironment}-rg'
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
