param elasticsearchFqdn string
param managedEnvironmentId string
param location string = 'northeurope'
param tag string = '7.17.4'
param addEnvs array = []

var initialEnvs = [
  {
    name: 'ELASTICSEARCH_HOSTS'
    value: '["https://${elasticsearchFqdn}"]'
  }
  {
    name: 'NODE_OPTIONS'
    value: '--max-old-space-size=3072'
  }
]

var envs = concat(initialEnvs, addEnvs)
resource web 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: 'kibana'
  location: location
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 5601
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: 'docker.elastic.co/kibana/kibana:${tag}'
          name: 'kibana'
          env: envs
          resources: {
            cpu: '1.5'
            memory: '3Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 8
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '50'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = web.properties.configuration.ingress.fqdn
