################################################################################
# Root Main - Terraform PostgreSQL DSM Monitoring & Load Testing
# Calls monitoring and load-testing modules
################################################################################

module "monitoring" {
  source = "./modules/monitoring"

  monitoring_namespace              = var.monitoring_namespace
  mysql_targets                     = local.mysql_targets
  postgres_targets                  = local.postgres_targets
  prometheus_stack_chart_version    = var.prometheus_stack_chart_version
  mysql_exporter_chart_version      = var.mysql_exporter_chart_version
  postgres_exporter_chart_version   = var.postgres_exporter_chart_version
}

module "load_testing" {
  source = "./modules/load-testing"

  loadtest_namespace               = var.loadtest_namespace
  create_loadtest_namespace        = true
  pushgateway_enabled              = var.pushgateway_enabled
  pushgateway_chart_version        = var.pushgateway_chart_version
  blackbox_enabled                 = var.blackbox_enabled
  blackbox_exporter_chart_version  = var.blackbox_exporter_chart_version
  pgbench_enabled                  = local.pgbench_connection_ready
  pgbench_image                    = var.pgbench_image
  postgres_host                    = try(local.pgbench_connection.host, "localhost")
  postgres_port                    = try(local.pgbench_connection.port, 5432)
  postgres_sslmode                 = try(local.pgbench_connection.sslmode, var.pgbench_sslmode)
  pgbench_database                 = try(local.pgbench_connection.database, var.pgbench_database)
  pgbench_user                     = try(local.pgbench_connection.user, "pgbench")
  pgbench_password                 = try(local.pgbench_connection.password, "")
  pgbench_jobs                     = var.pgbench_jobs
}
