param kubeEnvironmentId string
param location string = 'northeurope'
param storageAccountKey string
param storageAccountName string
param storageContainerName string

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
          image: 'buoyantio/emojivoto-web:v12'
          name: 'emojivoto-web'
          env: [
            {
              name: 'WEB_PORT'
              value: '8080'
            }
//              value: 'emojivoto-emoji.internal.${environmentUniqueIdentifier}.${location}.azurecontainerapps.io:8080'
            {
              name: 'EMOJISVC_HOST'
              value: 'localhost:8080/v1.0/invoke/emojivoto-emoji'
            }
//              value: 'emojivoto-voting.internal.${environmentUniqueIdentifier}.${location}.azurecontainerapps.io:8080'
            {
              name: 'VOTINGSVC_HOST'
              value: 'localhost:8080/v1.0/invoke/emojivoto-voting'
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
      dapr: {
        enabled: true
        appPort: 8080
        appId: 'emojivoto-web'
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
