variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by the Helm provider."
  type        = string
  default     = "./kubeconfig"
}

variable "kubeconfig_context" {
  description = "Kubernetes context in kubeconfig. Set null to use current-context."
  type        = string
  default     = null
}

variable "mysql_default_credentials" {
  description = "Default credentials used when a MySQL target does not define user/password."
  type = object({
    user     = string
    password = string
  })
  sensitive = true

  default = {
    user     = "mysql"
    password = "mysql"
  }
}

variable "mysql_targets" {
  description = "List of MySQL endpoints for prometheus-mysql-exporter multipleTarget mode."
  type = list(object({
    endpoint = string
    name     = string
    port     = optional(number, 3306)
    user     = optional(string)
    password = optional(string)
  }))

  default = []
}

variable "postgres_default_credentials" {
  description = "Default credentials used when a PostgreSQL target does not define user/password."
  type = object({
    user     = string
    password = string
  })
  sensitive = true

  default = {
    user     = "postgresql"
    password = "postgresql"
  }
}

variable "postgres_targets" {
  description = "List of PostgreSQL endpoints for prometheus-postgres-exporter multipleTarget mode."
  type = list(object({
    endpoint      = string
    name          = string
    port          = optional(number, 5432)
    database_name = optional(string)
    user          = optional(string)
    password      = optional(string)
  }))

  default = []
}

variable "monitoring_namespace" {
  description = "Namespace for Prometheus, Grafana, exporters and probe resources."
  type        = string
  default     = "monitoring"
}

variable "loadtest_namespace" {
  description = "Namespace for pgbench runner and benchmark jobs."
  type        = string
  default     = "loadtest"
}

variable "blackbox_enabled" {
  description = "Deploy blackbox exporter and create TCP probe resources for DB endpoints."
  type        = bool
  default     = true
}

variable "blackbox_image" {
  description = "Container image for blackbox exporter."
  type        = string
  default     = "quay.io/prometheus/blackbox-exporter:v0.25.0"
}

variable "blackbox_probe_interval" {
  description = "Probe interval for external DB endpoint TCP checks."
  type        = string
  default     = "30s"
}

variable "pushgateway_enabled" {
  description = "Deploy Pushgateway and wire pgbench run metrics into Prometheus/Grafana."
  type        = bool
  default     = true
}

variable "grafana_dashboard_enabled" {
  description = "Publish the custom PostgreSQL performance dashboard to Grafana via ConfigMap sidecar."
  type        = bool
  default     = true
}

variable "pgbench_enabled" {
  description = "Deploy pgbench runner and optional benchmark jobs. Requires pgbench_connection with dedicated benchmark credentials."
  type        = bool
  default     = true
}

variable "pgbench_image" {
  description = "Container image used for pgbench runner and jobs."
  type        = string
  default     = "postgres:17.5"
}

variable "pushgateway_image" {
  description = "Container image for Prometheus Pushgateway."
  type        = string
  default     = "prom/pushgateway:v1.11.1"
}

variable "metrics_pusher_image" {
  description = "Container image for metrics pusher (curl utility)."
  type        = string
  default     = "curlimages/curl:8.7.1"
}

variable "db_cluster_metrics_enabled" {
  description = "Collect DSM DB cluster OS metrics from the DB Kubernetes cluster and push them to Pushgateway."
  type        = bool
  default     = false
}

variable "db_cluster_kubeconfig_path" {
  description = "Path to kubeconfig for the DSM DB Kubernetes cluster."
  type        = string
  default     = "./k8s-db.yaml"
}

variable "db_cluster_collector_image" {
  description = "Container image for the DSM DB cluster metrics collector."
  type        = string
  default     = "python:3.12-slim"
}

variable "db_cluster_poll_interval_seconds" {
  description = "Polling interval in seconds for DSM DB cluster OS metrics collection."
  type        = number
  default     = 30
}

variable "pushgateway_scrape_interval" {
  description = "Prometheus scrape interval for Pushgateway metrics."
  type        = string
  default     = "15s"
}

variable "test_profile" {
  description = "Benchmark profile aligned with DB class sizing."
  type        = string
  default     = "2c4g"

  validation {
    condition     = contains(["2c2g", "2c4g", "2c8g"], var.test_profile)
    error_message = "test_profile must be one of: 2c2g, 2c4g, 2c8g."
  }
}

variable "pgbench_database" {
  description = "Database name used by pgbench."
  type        = string
  default     = "postgres"
}

variable "pgbench_sslmode" {
  description = "sslmode passed to pgbench client connections."
  type        = string
  default     = "disable"
}

variable "pgbench_target_name" {
  description = "Optional postgres target name used only to inherit host/port for pgbench when pgbench_connection.host/port are omitted."
  type        = string
  default     = null
}

variable "pgbench_connection" {
  description = "Dedicated connection settings for pgbench. Use this to separate benchmark credentials/database from exporter monitoring credentials in postgres_targets."
  type = object({
    host     = optional(string)
    port     = optional(number)
    database = optional(string)
    user     = string
    password = string
    sslmode  = optional(string)
  })
  default   = null
  sensitive = true
}

variable "pgbench_jobs" {
  description = "Enable or disable benchmark jobs managed by Terraform."
  type = object({
    init = object({
      enabled = bool
      scale   = optional(number, 10)
    })
    smoke = object({
      enabled  = bool
      clients  = optional(number)
      threads  = optional(number)
      duration = optional(number)
    })
    baseline_rw = object({
      enabled  = bool
      clients  = optional(number)
      threads  = optional(number)
      duration = optional(number)
    })
    baseline_ro = object({
      enabled  = bool
      clients  = optional(number)
      threads  = optional(number)
      duration = optional(number)
    })
    ramp = object({
      enabled  = bool
      steps    = optional(string)
      threads  = optional(number)
      duration = optional(number)
    })
    data_sweep_10m = object({
      enabled      = bool
      reinitialize = optional(bool, true)
      scale        = optional(number)
      clients      = optional(number)
      threads      = optional(number)
      duration     = optional(number)
    })
    data_sweep_20m = object({
      enabled      = bool
      reinitialize = optional(bool, true)
      scale        = optional(number)
      clients      = optional(number)
      threads      = optional(number)
      duration     = optional(number)
    })
    stress = object({
      enabled  = bool
      steps    = optional(string)
      threads  = optional(number)
      duration = optional(number)
    })
    ha_observation = object({
      enabled  = bool
      clients  = optional(number)
      threads  = optional(number)
      duration = optional(number)
    })
    soak = object({
      enabled  = bool
      clients  = optional(number)
      threads  = optional(number)
      duration = optional(number)
    })
  })

  default = {
    init           = { enabled = false, scale = 10 }
    smoke          = { enabled = false }
    baseline_rw    = { enabled = false }
    baseline_ro    = { enabled = false }
    ramp           = { enabled = false }
    data_sweep_10m = { enabled = false, reinitialize = true }
    data_sweep_20m = { enabled = false, reinitialize = true }
    stress         = { enabled = false }
    ha_observation = { enabled = false }
    soak           = { enabled = false }
  }
}

variable "prometheus_stack_chart_version" {
  description = "Prometheus stack Helm chart version"
  type        = string
  default     = "82.16.0"
}

variable "mysql_exporter_chart_version" {
  description = "MySQL exporter Helm chart version"
  type        = string
  default     = "2.13.0"
}

variable "postgres_exporter_chart_version" {
  description = "PostgreSQL exporter Helm chart version"
  type        = string
  default     = "7.5.2"
}

variable "pushgateway_chart_version" {
  description = "Pushgateway Helm chart version"
  type        = string
  default     = "2.0.4"
}

variable "blackbox_exporter_chart_version" {
  description = "Blackbox exporter Helm chart version"
  type        = string
  default     = "9.0.3"
}
