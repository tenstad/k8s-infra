{
  grafanaDashboards:: {
    http: (import 'http.jsonnet'),
    blackbox: (import 'blackbox.jsonnet'),
    nginx: (import 'nginx.jsonnet'),
    trivy: (import 'trivy.jsonnet'),
    goweb: (import 'goweb.jsonnet'),
  },
}
