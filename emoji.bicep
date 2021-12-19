param kubeEnvironmentId string
param location string = 'northeurope'
param storageAccountKey string
param storageAccountName string
param storageContainerName string

resource emoji 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'emojivoto-emoji'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: false
        targetPort: 8080
      }
      secrets: [
        {
          name: 'storage-key'
          value: storageAccountKey
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'buoyantio/emojivoto-emoji-svc:v12'
          name: 'emojivoto-emoji'
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
      dapr: {
        enabled: true
        appPort: 8080
        appId: 'emojivoto-emoji'
        components: [
          {
            name: 'statestore'
            type: 'state.azure.blobstorage'
            version: 'v1'
            metadata: [
              {
                name: 'accountName'
                value: storageAccountName
              }
              {
                name: 'accountKey'
                secretRef: 'storage-key'
              }
              {
                name: 'containerName'
                value: storageContainerName
              }
            ]
          }
        ]
      }
    }
  }
}
