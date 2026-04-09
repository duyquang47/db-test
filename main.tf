################################################################################
# Root Main - Terraform PostgreSQL DSM Monitoring & Load Testing
# Calls monitoring and load-testing modules
################################################################################

module "monitoring" {
  source = "./modules/monitoring"

  monitoring_namespace            = var.monitoring_namespace
  mysql_targets                   = local.mysql_targets
  postgres_targets                = local.postgres_targets
  prometheus_stack_chart_version  = var.prometheus_stack_chart_version
  mysql_exporter_chart_version    = var.mysql_exporter_chart_version
  postgres_exporter_chart_version = var.postgres_exporter_chart_version
}

module "load_testing" {
  source = "./modules/load-testing"

  monitoring_namespace             = var.monitoring_namespace
  loadtest_namespace               = var.loadtest_namespace
  create_loadtest_namespace        = true
  prometheus_release_name          = module.monitoring.prometheus_stack_release_name
  probe_targets                    = local.probe_targets
  pushgateway_enabled              = var.pushgateway_enabled
  pushgateway_chart_version        = var.pushgateway_chart_version
  pushgateway_image                = var.pushgateway_image
  pushgateway_scrape_interval      = var.pushgateway_scrape_interval
  blackbox_enabled                 = var.blackbox_enabled
  blackbox_exporter_chart_version  = var.blackbox_exporter_chart_version
  blackbox_image                   = var.blackbox_image
  blackbox_probe_interval          = var.blackbox_probe_interval
  grafana_dashboard_enabled        = var.grafana_dashboard_enabled
  pgbench_enabled                  = local.loadtest_enabled
  pgbench_image                    = var.pgbench_image
  metrics_pusher_image             = var.metrics_pusher_image
  db_cluster_metrics_enabled       = var.db_cluster_metrics_enabled
  db_cluster_kubeconfig_content    = var.db_cluster_metrics_enabled ? file(var.db_cluster_kubeconfig_path) : ""
  db_cluster_collector_image       = var.db_cluster_collector_image
  db_cluster_poll_interval_seconds = var.db_cluster_poll_interval_seconds
  test_profile                     = var.test_profile
  postgres_host                    = try(local.pgbench_connection.host, "localhost")
  postgres_port                    = try(local.pgbench_connection.port, 5432)
  postgres_sslmode                 = try(local.pgbench_connection.sslmode, var.pgbench_sslmode)
  pgbench_database                 = try(local.pgbench_connection.database, var.pgbench_database)
  pgbench_target_name              = try(local.pgbench_target.name, null)
  pgbench_user                     = try(local.pgbench_connection.user, "pgbench")
  pgbench_password                 = try(local.pgbench_connection.password, "")
  pgbench_jobs                     = var.pgbench_jobs
}
