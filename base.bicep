targetScope = 'subscription'
//
// verify the application with log analytics in
// ContainerAppConsoleLogs_CL | where ContainerAppName_s in ('emojivoto-web', 'emojivoto-voting', 'emojivoto-emoji') and ContainerName_s <> 'daprd' | project Log_s, TimeGenerated, ContainerAppName_s, ContainerName_s
//
param kubeEnvironment string = 'test'
param location string = 'northeurope'
param storageContainerName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'nicx-${kubeEnvironment}-rg'
  location: location
}

module sa './storageaccount.bicep' = {
  name: 'daprstorage'
  params: {
    kubeEnvironment: kubeEnvironment
  }
  scope: rg
}

module containerapps './apps.bicep' = {
  name: 'apps'
  scope: rg
  params: {
    location: location
    kubeEnvironment: kubeEnvironment
    storageAccountKey: sa.outputs.sasToken
    storageContainerName: storageContainerName
  }
}
