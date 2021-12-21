param elasticsearchFqdn string
param kubeEnvironmentId string
param location string = 'northeurope'
param tag string = '7.16.2'

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
              value: '["https://${elasticsearchFqdn}"]'
            }
            {
              name: 'NODE_OPTIONS'
              value: '--max-old-space-size=3072'
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
