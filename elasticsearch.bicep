param managedEnvironmentId string
param location string = 'northeurope'
param tag string = '8.2.2'

var port = 9200

resource elasticsearch 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: 'elasticsearch'
  location: location
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: false
        targetPort: port
        transport: 'auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: true
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
            {
              name: 'xpack.security.enabled'
              value: 'false'
            }
            {
              name: 'xpack.security.http.ssl.enabled'
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


output fqdn string = elasticsearch.properties.configuration.ingress.fqdn
