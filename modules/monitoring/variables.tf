variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_stack_chart_version" {
  description = "Prometheus stack Helm chart version"
  type        = string
  default     = "~> 60.0"
}

variable "mysql_exporter_chart_version" {
  description = "MySQL exporter Helm chart version"
  type        = string
  default     = "~> 2.0"
}

variable "postgres_exporter_chart_version" {
  description = "PostgreSQL exporter Helm chart version"
  type        = string
  default     = "~> 0.0"
}

variable "mysql_targets" {
  description = "MySQL targets for exporter"
  type = list(object({
    endpoint = string
    name     = string
    port     = number
    user     = string
    password = string
  }))
  default = []
}

variable "postgres_targets" {
  description = "PostgreSQL targets for exporter"
  type = list(object({
    endpoint      = string
    name          = string
    port          = number
    user          = string
    password      = string
    database_name = optional(string)
  }))
  default = []
}
