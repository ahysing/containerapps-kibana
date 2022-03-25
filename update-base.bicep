targetScope = 'subscription'
param kibanaFqdn string
param kubeEnvironment string
param location string = 'northeurope'
param tag string = '7.16.2'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'nicx-${kubeEnvironment}-rg'
  scope: subscription()
}

module update './update-kibana.bicep' = {
  name: 'update-kibana'
  params: {
    kibanaFqdn: kibanaFqdn
    kubeEnvironment: kubeEnvironment
    location: location
    tag: tag
  }
  scope: rg
}
