################################################################################
# Load Testing Addons Module
# Local Helm chart: blackbox exporter, probes, Pushgateway, pgbench runner/jobs
################################################################################

locals {
  addons_chart_path     = "${path.module}/charts/postgres-dsm-test-stack"
  dashboard_source_path = "${path.module}/charts/postgres-dsm-test-stack/dashboards/postgres-performance-test-metrics-dashboard.json"
}

resource "helm_release" "pg_dsm_test_addons" {
  name            = "pg-dsm-test"
  chart           = local.addons_chart_path
  namespace       = var.monitoring_namespace
  upgrade_install = true

  values = [
    yamlencode({
      namespaceManagement = {
        createMonitoring = false
        createLoadtest   = var.create_loadtest_namespace && var.pgbench_enabled
      }
      namespaces = {
        monitoring = var.monitoring_namespace
        loadtest   = var.loadtest_namespace
      }
      testProfile = var.test_profile
      images = {
        blackboxExporter   = var.blackbox_image
        pgbench            = var.pgbench_image
        pushgateway        = var.pushgateway_image
        metricsPusher      = var.metrics_pusher_image
        dbClusterCollector = var.db_cluster_collector_image
      }
      blackboxExporter = {
        enabled = var.blackbox_enabled
      }
      pushgateway = {
        enabled = var.pushgateway_enabled
        serviceMonitor = {
          enabled  = var.pushgateway_enabled
          interval = var.pushgateway_scrape_interval
          additionalLabels = {
            release = var.prometheus_release_name
          }
        }
      }
      grafanaDashboards = {
        enabled  = var.grafana_dashboard_enabled
        checksum = filesha256(local.dashboard_source_path)
      }
      probes = {
        enabled  = var.blackbox_enabled
        interval = var.blackbox_probe_interval
        additionalLabels = {
          release = var.prometheus_release_name
        }
        targets = var.probe_targets
      }
      postgres = {
        host              = var.postgres_host
        port              = var.postgres_port
        benchmarkDatabase = var.pgbench_database
        sslmode           = var.postgres_sslmode
        pgbenchUser       = var.pgbench_user
        pgbenchPassword   = var.pgbench_password
      }
      loadtest = {
        runner = {
          enabled = var.pgbench_enabled
        }
      }
      dbClusterMetrics = {
        enabled             = var.db_cluster_metrics_enabled
        kubeconfig          = var.db_cluster_kubeconfig_content
        pollIntervalSeconds = var.db_cluster_poll_interval_seconds
        targetName          = coalesce(var.pgbench_target_name, var.postgres_host)
        targetHost          = var.postgres_host
        targetPort          = var.postgres_port
      }
      jobs = {
        init = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.init.enabled
          ttlSecondsAfterFinished = 86400
          scale                   = tostring(try(var.pgbench_jobs.init.scale, 10))
        }
        smoke = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.smoke.enabled
          ttlSecondsAfterFinished = 86400
          clients                 = try(tostring(var.pgbench_jobs.smoke.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.smoke.threads), null)
          duration                = try(tostring(var.pgbench_jobs.smoke.duration), null)
        }
        baselineRw = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.baseline_rw.enabled
          ttlSecondsAfterFinished = 86400
          clients                 = try(tostring(var.pgbench_jobs.baseline_rw.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.baseline_rw.threads), null)
          duration                = try(tostring(var.pgbench_jobs.baseline_rw.duration), null)
        }
        baselineRo = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.baseline_ro.enabled
          ttlSecondsAfterFinished = 86400
          clients                 = try(tostring(var.pgbench_jobs.baseline_ro.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.baseline_ro.threads), null)
          duration                = try(tostring(var.pgbench_jobs.baseline_ro.duration), null)
        }
        ramp = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.ramp.enabled
          ttlSecondsAfterFinished = 86400
          steps                   = try(var.pgbench_jobs.ramp.steps, null)
          threads                 = try(tostring(var.pgbench_jobs.ramp.threads), null)
          duration                = try(tostring(var.pgbench_jobs.ramp.duration), null)
        }
        dataSweep10m = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.data_sweep_10m.enabled
          ttlSecondsAfterFinished = 86400
          scale                   = try(tostring(var.pgbench_jobs.data_sweep_10m.scale), "100")
          reinitialize            = try(var.pgbench_jobs.data_sweep_10m.reinitialize, true)
          clients                 = try(tostring(var.pgbench_jobs.data_sweep_10m.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.data_sweep_10m.threads), null)
          duration                = try(tostring(var.pgbench_jobs.data_sweep_10m.duration), null)
        }
        dataSweep20m = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.data_sweep_20m.enabled
          ttlSecondsAfterFinished = 86400
          scale                   = try(tostring(var.pgbench_jobs.data_sweep_20m.scale), "200")
          reinitialize            = try(var.pgbench_jobs.data_sweep_20m.reinitialize, true)
          clients                 = try(tostring(var.pgbench_jobs.data_sweep_20m.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.data_sweep_20m.threads), null)
          duration                = try(tostring(var.pgbench_jobs.data_sweep_20m.duration), null)
        }
        stress = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.stress.enabled
          ttlSecondsAfterFinished = 86400
          steps                   = try(var.pgbench_jobs.stress.steps, null)
          threads                 = try(tostring(var.pgbench_jobs.stress.threads), null)
          duration                = try(tostring(var.pgbench_jobs.stress.duration), null)
        }
        haObservation = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.ha_observation.enabled
          ttlSecondsAfterFinished = 86400
          clients                 = try(tostring(var.pgbench_jobs.ha_observation.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.ha_observation.threads), null)
          duration                = try(tostring(var.pgbench_jobs.ha_observation.duration), null)
        }
        soak = {
          enabled                 = var.pgbench_enabled && var.pgbench_jobs.soak.enabled
          ttlSecondsAfterFinished = 86400
          clients                 = try(tostring(var.pgbench_jobs.soak.clients), null)
          threads                 = try(tostring(var.pgbench_jobs.soak.threads), null)
          duration                = try(tostring(var.pgbench_jobs.soak.duration), null)
        }
      }
    })
  ]
}
