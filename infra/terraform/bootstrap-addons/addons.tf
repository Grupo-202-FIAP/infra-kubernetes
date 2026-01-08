resource "helm_release" "datadog" {
  name       = "datadog"
  namespace  = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"

  create_namespace = false

  set {
    name  = "datadog.apiKeyExistingSecret"
    value = "datadog-secret"
  }

  set {
    name  = "datadog.clusterName"
    value = data.terraform_remote_state.cluster.outputs.cluster_name
  }

  depends_on = [
    kubernetes_namespace.datadog,
    kubernetes_manifest.datadog_external_secret,
    data.terraform_remote_state.bootstrap_core
  ]
}
