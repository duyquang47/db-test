variable "monitoring_namespace" {
  description = "Monitoring namespace where addon release is installed."
  type        = string
}

variable "loadtest_namespace" {
  description = "Kubernetes namespace for load testing."
  type        = string
  default     = "loadtest"
}

variable "create_loadtest_namespace" {
  description = "Whether addon chart should create loadtest namespace."
  type        = bool
  default     = true
}

variable "prometheus_release_name" {
  description = "Prometheus stack release name used in ServiceMonitor/Probe labels."
  type        = string
}

variable "probe_targets" {
  description = "Normalized DB probe targets for blackbox exporter."
  type = list(object({
    name     = string
    engine   = string
    endpoint = string
    port     = number
  }))
  default = []
}

variable "pushgateway_enabled" {
  description = "Deploy Pushgateway."
  type        = bool
  default     = true
}

variable "pushgateway_chart_version" {
  description = "Retained for interface compatibility; chart version is managed in the local addon chart path."
  type        = string
  default     = "2.0.4"
}

variable "pushgateway_image" {
  description = "Pushgateway image."
  type        = string
  default     = "prom/pushgateway:v1.11.1"
}

variable "pushgateway_scrape_interval" {
  description = "Scrape interval for Pushgateway ServiceMonitor."
  type        = string
  default     = "15s"
}

variable "blackbox_enabled" {
  description = "Deploy blackbox exporter and probes."
  type        = bool
  default     = true
}

variable "blackbox_exporter_chart_version" {
  description = "Retained for interface compatibility; chart version is managed in the local addon chart path."
  type        = string
  default     = "9.0.3"
}

variable "blackbox_image" {
  description = "Blackbox exporter image."
  type        = string
  default     = "quay.io/prometheus/blackbox-exporter:v0.25.0"
}

variable "blackbox_probe_interval" {
  description = "Probe interval for blackbox TCP checks."
  type        = string
  default     = "30s"
}

variable "grafana_dashboard_enabled" {
  description = "Publish custom Grafana dashboard via ConfigMap sidecar."
  type        = bool
  default     = true
}

variable "pgbench_enabled" {
  description = "Enable pgbench runner and jobs."
  type        = bool
  default     = true
}

variable "pgbench_image" {
  description = "pgbench image."
  type        = string
  default     = "postgres:17.5"
}

variable "metrics_pusher_image" {
  description = "Image for Pushgateway metrics pusher sidecar."
  type        = string
  default     = "curlimages/curl:8.7.1"
}

variable "db_cluster_metrics_enabled" {
  description = "Enable DSM DB cluster OS metrics collector."
  type        = bool
  default     = false
}

variable "db_cluster_kubeconfig_content" {
  description = "Raw kubeconfig content for the DSM DB Kubernetes cluster."
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_cluster_collector_image" {
  description = "Image used by the DSM DB cluster metrics collector."
  type        = string
  default     = "python:3.12-slim"
}

variable "db_cluster_poll_interval_seconds" {
  description = "Polling interval in seconds for DSM DB cluster metrics collection."
  type        = number
  default     = 30
}

variable "test_profile" {
  description = "Benchmark profile."
  type        = string
  default     = "2c4g"
}

variable "postgres_host" {
  description = "PostgreSQL host for pgbench."
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port for pgbench."
  type        = number
  default     = 5432
}

variable "postgres_sslmode" {
  description = "SSL mode for pgbench."
  type        = string
  default     = "disable"
}

variable "pgbench_database" {
  description = "Benchmark database name."
  type        = string
}

variable "pgbench_target_name" {
  description = "Resolved postgres target name for output metadata."
  type        = string
  default     = null
}

variable "pgbench_user" {
  description = "Benchmark database user."
  type        = string
}

variable "pgbench_password" {
  description = "Benchmark database password."
  type        = string
  sensitive   = true
}

variable "pgbench_jobs" {
  description = "Benchmark job configuration."
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
}
