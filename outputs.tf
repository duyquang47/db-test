################################################################################
# Root Module Outputs - Modular Architecture
################################################################################

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = module.monitoring.prometheus_stack_namespace
}

output "loadtest_namespace" {
  description = "Load testing namespace"
  value       = module.load_testing.loadtest_namespace
}

output "monitoring_summary" {
  description = "Monitoring module summary"
  value = {
    prometheus_stack_release = module.monitoring.prometheus_stack_release_name
    mysql_exporter_enabled   = module.monitoring.mysql_exporter_enabled
    postgres_exporter_enabled = module.monitoring.postgres_exporter_enabled
  }
}

output "load_testing_summary" {
  description = "Load testing module summary"
  value = {
    pushgateway_enabled       = module.load_testing.pushgateway_enabled
    blackbox_exporter_enabled = module.load_testing.blackbox_exporter_enabled
    pgbench_jobs_deployed     = module.load_testing.pgbench_jobs_deployed
  }
}
