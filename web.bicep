param kubeEnvironmentId string
param location string = 'northeurope'
param emojiFqdn string
param emojiPort string
param votingFqdn string
param votingPort string

resource web 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'emojivoto-web'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
    }
    template: {
      containers: [
        {
          image: 'buoyantio/emojivoto-web:v12'
          name: 'emojivoto-web'
          env: [
            {
              name: 'WEB_PORT'
              value: '8080'
            }
            {
              name: 'EMOJISVC_HOST'
              value: '${emojiFqdn}:${emojiPort}'
            }
            {
              name: 'VOTINGSVC_HOST'
              value: '${votingFqdn}:${votingPort}'
            }
            {
              name: 'INDEX_BUNDLE'
              value: 'dist/index_bundle.js'
            }
          ]
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 8
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = web.properties.configuration.ingress.fqdn
