output "prometheus_stack_release_name" {
  description = "Prometheus stack Helm release name"
  value       = helm_release.prometheus_stack.name
}

output "prometheus_stack_namespace" {
  description = "Prometheus stack Kubernetes namespace"
  value       = helm_release.prometheus_stack.namespace
}

output "mysql_exporter_enabled" {
  description = "Whether MySQL exporter is deployed"
  value       = length(helm_release.mysql_exporter) > 0
}

output "postgres_exporter_enabled" {
  description = "Whether PostgreSQL exporter is deployed"
  value       = length(helm_release.postgres_exporter) > 0
}
