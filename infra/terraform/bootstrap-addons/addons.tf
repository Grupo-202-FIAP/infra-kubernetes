resource "helm_release" "datadog" {
  name       = "datadog"
  namespace  = "default"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"

  create_namespace = false
  timeout          = 600
  wait             = true

  # API KEY (External Secret)
  set {
    name  = "datadog.apiKeyExistingSecret"
    value = "datadog-secret"
  }

  # Nome do cluster
  set {
    name  = "datadog.clusterName"
    value = data.terraform_remote_state.cluster.outputs.cluster_name
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  # -----------------------------
  # Logs
  # -----------------------------
  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  # -----------------------------
  # APM
  # -----------------------------
  set {
    name  = "datadog.apm.enabled"
    value = "true"
  }

  # -----------------------------
  # Kubernetes metrics (KSM)
  # -----------------------------
  set {
    name  = "datadog.kubeStateMetricsEnabled"
    value = "true"
  }

  # -----------------------------
  # Process Agent
  # -----------------------------
  set {
    name  = "datadog.processAgent.enabled"
    value = "true"
  }

  set {
    name  = "datadog.admissionController.enabled"
    value = "true"
  }

  depends_on = [
    kubernetes_manifest.datadog_external_secret,
    data.terraform_remote_state.bootstrap_core
  ]
}
