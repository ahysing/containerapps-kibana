param kubeEnvironmentId string
param location string = 'northeurope'
param tag string = '7.16.2'

var port = 9200

resource emoji 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'elasticsearch'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: kubeEnvironmentId
    configuration: {
      ingress: {
        external: false
        targetPort: port
        transport: 'auto'
      }
      secrets: [
      ]
    }
    template: {
      containers: [
        {
          image: 'docker.elastic.co/elasticsearch/elasticsearch:${tag}'
          name: 'elasticsearch'
          env: [
            {
              name: 'http.cors.enabled'
              value: 'true'
            }
            {
              name: 'http.cors.allow-origin'
              value: '/.*/'
            }
            {
              name: 'discovery.type'
              value: 'single-node'
            }
            {
              name: 'ES_JAVA_OPTS'
              value: '-Xms2g -Xmx2g'
            }
            {
              name: 'ingest.geoip.downloader.enabled'
              value: 'false'
            }
          ]
          resources: {
            cpu: 2
            memory: '4Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}


output fqdn string = emoji.properties.configuration.ingress.fqdn
