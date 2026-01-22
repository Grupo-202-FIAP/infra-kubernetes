resource "helm_release" "datadog" {
  name       = "datadog"
  namespace  = "default"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"

  create_namespace = false
  timeout          = 600
  wait             = true

  set {
    name  = "datadog.apiKeyExistingSecret"
    value = "datadog-secret"
  }

  set {
    name  = "datadog.clusterName"
    value = data.terraform_remote_state.cluster.outputs.cluster_name
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  # Logs
  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  # APM
  set {
    name  = "datadog.apm.enabled"
    value = "true"
  }

  # K8s Metrics
  set {
    name  = "datadog.kubeStateMetricsEnabled"
    value = "true"
  }

  # Process Agent
  set {
    name  = "datadog.processAgent.enabled"
    value = "true"
  }

  # Resources
  set {
    name  = "agents.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "agents.resources.requests.memory"
    value = "200Mi"
  }

  set {
    name  = "clusterAgent.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "clusterAgent.resources.requests.memory"
    value = "256Mi"
  }

  depends_on = [
    kubernetes_manifest.datadog_external_secret
  ]
}
