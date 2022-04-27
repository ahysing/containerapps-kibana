param kibanaFqdn string
param kubeEnvironment string
param location string
param tag string

resource elasticsearch 'Microsoft.App/containerapps@2022-01-01-preview' existing = {
  name: 'elasticsearch'
}

var managedEnvironmentId = resourceId('Microsoft.App/managedEnvironments', kubeEnvironment)
resource web 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: 'kibana'
  location: location
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 5601
      }
      traffic: [
        {
          weight: 100
          latestRevision: true
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'docker.elastic.co/kibana/kibana:${tag}'
          name: 'kibana'
          env: [
            {
              name: 'ELASTICSEARCH_HOSTS'
              value: '["https://${elasticsearch.properties.latestRevisionFqdn}"]' // read the latest FQDN
            }
            {
              name: 'NODE_OPTIONS'
              value: '--max-old-space-size=3072'
            }
            {
              name: 'SERVER_PUBLICBASEURL'
              value: kibanaFqdn // Pass the kibana FQDN
            }
          ]
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
