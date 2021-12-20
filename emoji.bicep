param kubeEnvironmentId string
param location string = 'northeurope'
param tag string

var port = 8080

resource emoji 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'emojivoto-emoji'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: false
        targetPort: port
        transport: 'http2'
        allowInsecure: true
      }
      secrets: [
      ]
    }
    template: {
      containers: [
        {
          image: 'buoyantio/emojivoto-emoji-svc:${tag}'
          name: 'emojivoto-emoji'
          env: [
            {
              name: 'GRPC_PORT'
              value: '${port}'
            }
          ]
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
}


output fqdn string = emoji.properties.configuration.ingress.fqdn
output port string = '${port}'
