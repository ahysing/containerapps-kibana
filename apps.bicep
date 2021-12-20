param kubeEnvironment string
param location string = 'northeurope'

var workspaceName = 'nicx-${kubeEnvironment}-la'
param tag string = '7.16.2'

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

// https://blog.johnnyreilly.com/2021/12/19/azure-container-apps-bicep-and-github-actions/
resource ke 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: kubeEnvironment
  location: location
  properties: {
    type: 'Managed'
//    internalLoadBalancerEnabled: false // this is a requirement for GRPC
    internalLoadBalancerEnabled: true
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: listKeys(workspace.id, workspace.apiVersion).primarySharedKey
      }
    }
  }
}

var kubeEnvironmentId = resourceId('Microsoft.Web/kubeEnvironments', kubeEnvironment)

module elasticsearch './elasticsearch.bicep' = {
  name: 'elasticsearch'
  params: {
    kubeEnvironmentId: kubeEnvironmentId
    location: location
    tag: tag
  }
  dependsOn: [
    ke
  ]
}

module web './web.bicep' = {
  name: 'web'
  params: {
    elasticsearchFqdn: elasticsearch.outputs.fqdn
    kubeEnvironmentId: kubeEnvironmentId
    location: location
    tag: tag
  }
  dependsOn: [
    ke
  ]
}
