param emojiFqdn string
param kubeEnvironmentId string
param location string = 'northeurope'
param tag string
param votingFqdn string

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
          image: 'buoyantio/emojivoto-web:${tag}'
          name: 'emojivoto-web'
          env: [
            {
              name: 'WEB_PORT'
              value: '8080'
            }
            {
              name: 'EMOJISVC_HOST'
              value: 'dns://${emojiFqdn}:443'
            }
            {
              name: 'VOTINGSVC_HOST'
              value: 'dns://${votingFqdn}:443'
            }
            {
              name: 'INDEX_BUNDLE'
              value: 'dist/index_bundle.js'
            }
            {
              name: 'GRPC_GO_LOG_VERBOSITY_LEVEL'
              value: '99'
            }
            {
              name: 'GRPC_GO_LOG_SEVERITY_LEVEL'
              value: 'info'
            }
            {
              name: 'GODEBUG'
              value: 'http2debug=2'
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
