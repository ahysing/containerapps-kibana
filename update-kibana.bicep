param kibanaFqdn string
param kubeEnvironment string
param location string
param tag string

resource elasticsearch 'Microsoft.Web/containerapps@2021-03-01' existing = {
  name: 'elasticsearch'
}

var kubeEnvironmentId = resourceId('Microsoft.Web/kubeEnvironments', kubeEnvironment)
resource web 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'kibana'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 5601
      }
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
