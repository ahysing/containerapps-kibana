param kubeEnvironmentId string
param location string = 'northeurope'
param storageAccountKey string
param storageAccountName string
param storageContainerName string

resource voting 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'emojivoto-voting'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: false
        targetPort: 8080
      }
    }
    template: {
      containers: [
        {
          image: 'buoyantio/emojivoto-voting-svc:v12'
          name: 'emojivoto-voting'
          env: [
            {
              name: 'GRPC_PORT'
              value: '8080'
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
      dapr: {
        enabled: true
        appPort: 8080
        appId: 'emojivoto-voting'
      }
    }
  }
}
