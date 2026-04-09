output "loadtest_namespace" {
  description = "Loadtest namespace name"
  value       = var.loadtest_namespace
}

output "pushgateway_enabled" {
  description = "Pushgateway deployment status"
  value       = var.pushgateway_enabled
}

output "blackbox_exporter_enabled" {
  description = "Blackbox exporter deployment status"
  value       = var.blackbox_enabled
}

output "pgbench_jobs_deployed" {
  description = "Number of pgbench jobs deployed"
  value = (
    (var.pgbench_jobs.init.enabled ? 1 : 0) +
    (var.pgbench_jobs.smoke.enabled ? 1 : 0) +
    (var.pgbench_jobs.baseline_rw.enabled ? 1 : 0) +
    (var.pgbench_jobs.baseline_ro.enabled ? 1 : 0) +
    (var.pgbench_jobs.stress.enabled ? 1 : 0)
  )
}
