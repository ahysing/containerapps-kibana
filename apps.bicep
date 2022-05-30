param kubeEnvironment string
param location string = 'northeurope'

var workspaceName = 'nicx-${kubeEnvironment}-la'
param tag string = '7.17.4'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {}
  }
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: kubeEnvironment
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: listKeys(workspace.id, workspace.apiVersion).primarySharedKey
      }
    }
  }
}

var managedEnvironmentId = resourceId('Microsoft.App/managedEnvironments', kubeEnvironment)

module elasticsearch './elasticsearch.bicep' = {
  name: 'elasticsearch'
  params: {
    managedEnvironmentId: managedEnvironmentId
    location: location
    tag: '8.2.2'
  }
  dependsOn: [
    managedEnvironment
  ]
}

module web './web.bicep' = {
  name: 'web'
  params: {
    elasticsearchFqdn: elasticsearch.outputs.fqdn
    location: location
    managedEnvironmentId: managedEnvironmentId
    tag: tag
  }
  dependsOn: [
    managedEnvironment
  ]
}

module webUpdate './web.bicep' = {
  name: 'update-web'
  params: {
    addEnvs: [
      {
        name: 'SERVER_PUBLICBASEURL'
        value: 'https://${web.outputs.fqdn}'
      }
    ]
    elasticsearchFqdn: elasticsearch.outputs.fqdn
    location: location
    managedEnvironmentId: managedEnvironmentId
    tag: tag
  }
  dependsOn: [
    web
  ]
}

