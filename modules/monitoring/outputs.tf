output "prometheus_stack_release_name" {
  description = "Prometheus stack Helm release name"
  value       = helm_release.prometheus_stack.name
}

output "namespace" {
  description = "Namespace where monitoring stack is deployed."
  value       = helm_release.prometheus_stack.namespace
}

output "prometheus_stack_release" {
  description = "Main kube-prometheus-stack Helm release metadata."
  value = {
    name      = helm_release.prometheus_stack.name
    namespace = helm_release.prometheus_stack.namespace
    status    = helm_release.prometheus_stack.status
    version   = helm_release.prometheus_stack.version
  }
}

output "mysql_exporter_release" {
  description = "MySQL exporter Helm release metadata."
  value = {
    name      = helm_release.mysql_exporter.name
    namespace = helm_release.mysql_exporter.namespace
    status    = helm_release.mysql_exporter.status
    version   = helm_release.mysql_exporter.version
  }
}

output "postgres_exporter_release" {
  description = "PostgreSQL exporter Helm release metadata."
  value = {
    name      = helm_release.postgres_exporter.name
    namespace = helm_release.postgres_exporter.namespace
    status    = helm_release.postgres_exporter.status
    version   = helm_release.postgres_exporter.version
  }
}
