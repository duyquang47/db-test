################################################################################
# Monitoring Stack Module
# Helm releases: Prometheus-stack, MySQL Exporter, PostgreSQL Exporter
################################################################################

# Prometheus Stack (Prometheus + Grafana + Alertmanager + Node Exporter)
resource "helm_release" "prometheus_stack" {
  name             = "kube-prom-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.monitoring_namespace
  create_namespace = true
  upgrade_install  = true
  version          = var.prometheus_stack_chart_version

  values = [file("${path.module}/../../config/helm-values/prometheus-stack.yaml")]
}

# MySQL Exporter
resource "helm_release" "mysql_exporter" {
  count           = length(var.mysql_targets) > 0 ? 1 : 0
  name            = "prom-mysql-exporter"
  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "prometheus-mysql-exporter"
  namespace       = var.monitoring_namespace
  upgrade_install = true
  version         = var.mysql_exporter_chart_version

  values = [
    file("${path.module}/../../config/helm-values/prometheus-mysql-exporter.yaml"),
    yamlencode({
      serviceMonitor = {
        enabled = length(var.mysql_targets) > 0
        multipleTarget = {
          enabled = true
          targets = var.mysql_targets
        }
      }
    })
  ]

  depends_on = [helm_release.prometheus_stack]
}

# PostgreSQL Exporter
resource "helm_release" "postgres_exporter" {
  count           = length(var.postgres_targets) > 0 ? 1 : 0
  name            = "prom-postgres-exporter"
  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "prometheus-postgres-exporter"
  namespace       = var.monitoring_namespace
  upgrade_install = true
  version         = var.postgres_exporter_chart_version

  values = [
    file("${path.module}/../../config/helm-values/prometheus-postgres-exporter.yaml"),
    yamlencode({
      serviceMonitor = {
        enabled = length(var.postgres_targets) > 0
        multipleTarget = {
          enabled = true
          targets = [
            for target in var.postgres_targets : {
              endpoint      = target.endpoint
              name          = target.name
              port          = target.port
              databaseName  = try(target.database_name, null)
              username      = target.user
              password      = target.password
            }
          ]
        }
      }
    })
  ]

  depends_on = [helm_release.prometheus_stack]
}
