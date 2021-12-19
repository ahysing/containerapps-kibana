param kubeEnvironment string

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'nicx${kubeEnvironment}sa'
  location: resourceGroup().location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
}

// https://samcogan.com/generate-sas-tokens-in-arm-teamplates/
var accountSasProperties = {
  signedServices: 'b'
  signedPermission: 'rw'
  signedExpiry: '2024-08-20T11:00:00Z'
  signedResourceTypes: 's'
}

var sasToken = sa.listAccountSas('2021-04-01', accountSasProperties).accountSasToken


output storageAccount object = sa
output sasToken string = sasToken
