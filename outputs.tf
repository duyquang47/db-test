output "namespace" {
  description = "Namespace where monitoring stack is deployed."
  value       = module.monitoring.namespace
}

output "prometheus_stack_release" {
  description = "Main kube-prometheus-stack Helm release metadata."
  value       = module.monitoring.prometheus_stack_release
}

output "mysql_exporter_release" {
  description = "MySQL exporter Helm release metadata."
  value       = module.monitoring.mysql_exporter_release
}

output "postgres_exporter_release" {
  description = "PostgreSQL exporter Helm release metadata."
  value       = module.monitoring.postgres_exporter_release
}

output "blackbox_exporter" {
  description = "Blackbox exporter service and probe target summary."
  value       = module.load_testing.blackbox_exporter
}

output "pgbench_runner" {
  description = "pgbench runner deployment metadata."
  sensitive   = true
  value       = module.load_testing.pgbench_runner
}

output "pgbench_enabled_jobs" {
  description = "List of benchmark jobs enabled in Terraform."
  sensitive   = true
  value       = module.load_testing.pgbench_enabled_jobs
}

output "pg_dsm_test_addons_release" {
  description = "Local Helm chart release for blackbox exporter, probes, pgbench runner, and benchmark jobs."
  value       = module.load_testing.pg_dsm_test_addons_release
}
