# Computed locals for normalized target configurations
locals {
  # Normalize MySQL targets with default credentials
  mysql_targets = [
    for target in var.mysql_targets : {
      endpoint = target.endpoint
      name     = target.name
      port     = target.port
      user     = coalesce(try(target.user, null), var.mysql_default_credentials.user)
      password = coalesce(try(target.password, null), var.mysql_default_credentials.password)
    }
  ]

  # Normalize PostgreSQL targets with default credentials
  postgres_targets = [
    for target in var.postgres_targets : {
      endpoint      = target.endpoint
      name          = target.name
      port          = target.port
      database_name = try(target.database_name, null)
      user          = coalesce(try(target.user, null), var.postgres_default_credentials.user)
      password      = coalesce(try(target.password, null), var.postgres_default_credentials.password)
    }
  ]

  # Resolve pgbench target from postgres_targets if named reference provided
  pgbench_target = (
    var.pgbench_target_name != null
    ? try(one([for target in local.postgres_targets : target if target.name == var.pgbench_target_name]), null)
    : null
  )

  # Build pgbench connection details with fallbacks
  pgbench_connection = (
    var.pgbench_connection != null
    ? {
      host     = coalesce(try(var.pgbench_connection.host, null), try(local.pgbench_target.endpoint, null))
      port     = coalesce(try(var.pgbench_connection.port, null), try(local.pgbench_target.port, null), 5432)
      database = coalesce(try(var.pgbench_connection.database, null), var.pgbench_database)
      user     = var.pgbench_connection.user
      password = var.pgbench_connection.password
      sslmode  = coalesce(try(var.pgbench_connection.sslmode, null), var.pgbench_sslmode)
    }
    : null
  )

  # Determine if pgbench is ready to run (all required fields present)
  pgbench_connection_ready = (
    local.pgbench_connection != null &&
    try(local.pgbench_connection.host, null) != null &&
    try(local.pgbench_connection.user, null) != null &&
    try(local.pgbench_connection.password, null) != null
  )

  # Load testing is enabled only if pgbench is enabled AND connection is valid
  loadtest_enabled = var.pgbench_enabled && local.pgbench_connection_ready

  # Build probe targets for blackbox exporter (PostgreSQL + MySQL)
  probe_targets = concat(
    [
      for target in local.postgres_targets : {
        name     = "postgres-${target.name}"
        engine   = "postgres"
        endpoint = target.endpoint
        port     = target.port
      }
    ],
    [
      for target in local.mysql_targets : {
        name     = "mysql-${target.name}"
        engine   = "mysql"
        endpoint = target.endpoint
        port     = target.port
      }
    ]
  )

  # Service Monitor labels - reference monitoring module output
  service_monitor_labels = {
    release = module.monitoring.prometheus_stack_release_name
  }
}
