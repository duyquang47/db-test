################################################################################
# Monitoring Stack Module
# Helm releases: Prometheus-stack, MySQL Exporter, PostgreSQL Exporter
################################################################################

locals {
  prometheus_stack_chart_path  = "${path.module}/charts/kube-prometheus-stack-${var.prometheus_stack_chart_version}"
  mysql_exporter_chart_path    = "${path.module}/charts/prometheus-mysql-exporter-${var.mysql_exporter_chart_version}"
  postgres_exporter_chart_path = "${path.module}/charts/prometheus-postgres-exporter-${var.postgres_exporter_chart_version}"
}

resource "helm_release" "prometheus_stack" {
  name             = "kube-prom-stack"
  chart            = local.prometheus_stack_chart_path
  namespace        = var.monitoring_namespace
  create_namespace = true
  upgrade_install  = true

  values = [file("${path.module}/../../config/helm-values/prometheus-stack.yaml")]
}

resource "helm_release" "mysql_exporter" {
  name            = "prom-mysql-exporter"
  chart           = local.mysql_exporter_chart_path
  namespace       = var.monitoring_namespace
  upgrade_install = true

  values = [
    file("${path.module}/../../config/helm-values/prometheus-mysql-exporter.yaml"),
    yamlencode({
      serviceMonitor = {
        enabled = length(var.mysql_targets) > 0
        multipleTarget = {
          enabled = length(var.mysql_targets) > 0
          targets = var.mysql_targets
        }
      }
    })
  ]

  depends_on = [helm_release.prometheus_stack]
}

resource "helm_release" "postgres_exporter" {
  name            = "prom-postgres-exporter"
  chart           = local.postgres_exporter_chart_path
  namespace       = var.monitoring_namespace
  upgrade_install = true

  values = [
    file("${path.module}/../../config/helm-values/prometheus-postgres-exporter.yaml"),
    yamlencode({
      config = {
        extraArgs = [
          "--collector.stat_checkpointer",
        ]
        postgresExporter = yamlencode({
          auth_modules = {
            for target in var.postgres_targets : "client.${target.name}" => {
              type = "userpass"
              userpass = {
                username = target.user
                password = target.password
              }
              options = {
                sslmode = "disable"
              }
            }
          }
        })
      }
      serviceMonitor = {
        multipleTarget = {
          enabled = length(var.postgres_targets) > 0
          targets = [
            for target in var.postgres_targets : merge(
              {
                endpoint = target.endpoint
                name     = target.name
                port     = target.port
              },
              try(target.database_name, null) != null ? { databaseName = target.database_name } : {}
            )
          ]
        }
      }
    })
  ]

  depends_on = [helm_release.prometheus_stack]
}
