output "blackbox_exporter" {
  description = "Blackbox exporter service and probe target summary."
  value = var.blackbox_enabled ? {
    release   = helm_release.pg_dsm_test_addons.name
    name      = "pg-dsm-test-blackbox-exporter"
    namespace = var.monitoring_namespace
    targets   = [for target in var.probe_targets : "${target.engine}:${target.name}:${target.endpoint}:${target.port}"]
  } : null
}

output "pgbench_runner" {
  description = "pgbench runner deployment metadata."
  sensitive   = true
  value = var.pgbench_enabled ? {
    namespace    = var.loadtest_namespace
    release      = helm_release.pg_dsm_test_addons.name
    deployment   = "pg-dsm-test-pgbench-runner"
    test_profile = var.test_profile
    target_name  = var.pgbench_target_name
    database     = var.pgbench_database
  } : null
}

output "pgbench_enabled_jobs" {
  description = "List of benchmark jobs enabled in Terraform."
  sensitive   = true
  value = [
    for job_name, cfg in {
      init           = var.pgbench_jobs.init.enabled
      smoke          = var.pgbench_jobs.smoke.enabled
      baseline_rw    = var.pgbench_jobs.baseline_rw.enabled
      baseline_ro    = var.pgbench_jobs.baseline_ro.enabled
      ramp           = var.pgbench_jobs.ramp.enabled
      data_sweep_10m = var.pgbench_jobs.data_sweep_10m.enabled
      data_sweep_20m = var.pgbench_jobs.data_sweep_20m.enabled
      stress         = var.pgbench_jobs.stress.enabled
      ha_observation = var.pgbench_jobs.ha_observation.enabled
      soak           = var.pgbench_jobs.soak.enabled
    } : job_name if var.pgbench_enabled && cfg
  ]
}

output "pg_dsm_test_addons_release" {
  description = "Local Helm chart release for blackbox exporter, probes, pgbench runner, and benchmark jobs."
  value = {
    name      = helm_release.pg_dsm_test_addons.name
    namespace = helm_release.pg_dsm_test_addons.namespace
    status    = helm_release.pg_dsm_test_addons.status
    version   = helm_release.pg_dsm_test_addons.version
  }
}
