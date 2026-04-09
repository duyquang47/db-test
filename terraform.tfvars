################################################################################
# Terraform Configuration Example for PostgreSQL DSM Test Stack
# Copy this file to terraform.tfvars and customize for your environment
################################################################################

# Kubernetes Configuration
# Path to kubeconfig file for cluster access
kubeconfig_path = "./kubeconfig"

# Kubernetes context to use (null = use current-context)
kubeconfig_context = null

################################################################################
# MySQL Monitoring Configuration
################################################################################

# Default MySQL credentials (used when target doesn't specify user/password)
mysql_default_credentials = {
  user     = "admin"
  password = "ViettelZego2026"
}

# MySQL targets for monitoring via prometheus-mysql-exporter
# Leave empty [] if no MySQL monitoring needed
mysql_targets = [
  # {
  #   endpoint = "mysql.example.com"
  #   name     = "production-db"
  #   port     = 3306
  #   user     = "exporter_user"      # Optional, uses default if omitted
  #   password = "exporter_password"  # Optional, uses default if omitted
  # }
]

################################################################################
# PostgreSQL Monitoring Configuration
################################################################################

# Default PostgreSQL credentials (used when target doesn't specify user/password)
postgres_default_credentials = {
  user     = "pgadmin"
  password = "quang47"
}

# PostgreSQL targets for monitoring via prometheus-postgres-exporter
postgres_targets = [
  {
    endpoint      = "171.226.13.40"
    name          = "quangmxd"
    port          = 5432
    database_name = "quangmxd"
    user          = "quangmxd"
    password      = "quang47"
  }
]

################################################################################
# Kubernetes Namespace Configuration
################################################################################

# Namespace for monitoring stack (Prometheus, Grafana, Exporters, Probes)
monitoring_namespace = "monitoring"

# Namespace for load testing components (pgbench runner and jobs)
loadtest_namespace = "loadtest"

################################################################################
# Blackbox Exporter Configuration (TCP/ICMP availability checks)
################################################################################

blackbox_enabled = true

# Container image for blackbox exporter
blackbox_image = "quay.io/prometheus/blackbox-exporter:v0.25.0"

# Probe interval for external database connectivity checks
blackbox_probe_interval = "30s"

################################################################################
# Pushgateway Configuration (pgbench metrics aggregation)
################################################################################

pushgateway_enabled = true

# Container image for Prometheus Pushgateway
pushgateway_image = "prom/pushgateway:v1.11.1"

# Scrape interval for Pushgateway metrics in Prometheus
pushgateway_scrape_interval = "15s"

# Container image for metrics pusher utility (curl)
metrics_pusher_image = "curlimages/curl:8.7.1"

################################################################################
# Grafana Dashboard Configuration
################################################################################

# Enable custom PostgreSQL performance dashboard publication
grafana_dashboard_enabled = true

################################################################################
# pgbench Load Testing Configuration
################################################################################

# Enable pgbench runner and benchmark job deployment
pgbench_enabled = true

# Container image for pgbench (PostgreSQL client tools)
pgbench_image = "postgres:17.5"

# Benchmark test profile (controls concurrency, duration defaults)
# Valid options: 2c2g, 2c4g, 2c8g
test_profile = "2c8g"

# Default database for pgbench
pgbench_database = "pgbench"

# SSL mode for pgbench connections
pgbench_sslmode = "disable"

# Optional: Reference to PostgreSQL target for inheriting host/port
# If set, pgbench_connection can omit host/port
pgbench_target_name = "quangmxd"

# Dedicated pgbench connection settings (separate from monitoring exporters)
# REQUIRED if pgbench_enabled = true
pgbench_connection = {
  host     = "171.226.13.40"
  port     = 5432
  database = "quangmxd"
  user     = "quangmxd"
  password = "quang47"
  sslmode  = "disable"
}

################################################################################
# Benchmark Job Configuration
# All jobs are DISABLED by default - enable selectively for testing
################################################################################

pgbench_jobs = {
  # Initialization job - creates and prepares test data
  init = {
    enabled = true
    scale   = 20  # Database size scale factor
  }

  # Quick smoke test - verifies setup works
  smoke = {
    enabled = false
    # clients  = 1
    # threads  = 1
    # duration = 60
  }

  # Baseline workload - read/write mixed
  baseline_rw = {
    enabled = false
    # clients  = 20
    # threads  = 4
    # duration = 300
  }

  # Baseline workload - read-only
  baseline_ro = {
    enabled = false
    # clients  = 20
    # threads  = 4
    # duration = 300
  }

  # Ramp-up test - gradually increasing load
  ramp = {
    enabled = false
    # steps    = "4,8,16,32"
    # threads  = 2
    # duration = 60
  }

  # Data sweep test - 10M row scan
  data_sweep_10m = {
    enabled      = false
    reinitialize = true
    # scale    = 100
    # clients  = 10
    # threads  = 2
    # duration = 300
  }

  # Data sweep test - 20M row scan
  data_sweep_20m = {
    enabled      = false
    reinitialize = true
    # scale    = 200
    # clients  = 10
    # threads  = 2
    # duration = 300
  }

  # Stress test - maximum load
  stress = {
    enabled = false
    steps   = "50 100 150"
    threads  = 10
    duration = 300
  }

  # High availability observation - monitoring RTO/RPO during failover
  ha_observation = {
    enabled = false
    # clients  = 20
    # threads  = 4
    # duration = 600
  }

  # Soak test - sustained load over extended period
  soak = {
    enabled = false
    # clients  = 10
    # threads  = 2
    # duration = 3600
  }
}

################################################################################
# Backend Configuration Notes
################################################################################

# S3/MinIO Backend:
# - Credentials loaded from environment variables:
#   - AWS_ACCESS_KEY_ID
#   - AWS_SECRET_ACCESS_KEY
#
# Example (WSL):
#   export AWS_ACCESS_KEY_ID="minioadmin"
#   export AWS_SECRET_ACCESS_KEY="minioadmin"
#   terraform init
