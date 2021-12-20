param kubeEnvironmentId string
param location string = 'northeurope'
param tag string

var port = 8080

resource voting 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'emojivoto-voting'
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
          image: 'buoyantio/emojivoto-voting-svc:${tag}'
          name: 'emojivoto-voting'
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


output fqdn string = voting.properties.configuration.ingress.fqdn
output port string = '${port}'
