variable "loadtest_namespace" {
  description = "Kubernetes namespace for load testing"
  type        = string
  default     = "loadtest"
}

variable "create_loadtest_namespace" {
  description = "Create loadtest namespace"
  type        = bool
  default     = true
}

variable "pushgateway_enabled" {
  description = "Deploy Pushgateway"
  type        = bool
  default     = true
}

variable "pushgateway_chart_version" {
  description = "Pushgateway Helm chart version"
  type        = string
  default     = "~> 2.0"
}

variable "blackbox_enabled" {
  description = "Deploy Blackbox exporter"
  type        = bool
  default     = true
}

variable "blackbox_exporter_chart_version" {
  description = "Blackbox exporter Helm chart version"
  type        = string
  default     = "~> 9.0"
}

variable "pgbench_enabled" {
  description = "Enable pgbench load testing"
  type        = bool
  default     = true
}

variable "pgbench_image" {
  description = "pgbench container image"
  type        = string
  default     = "postgres:17.5"
}

variable "postgres_host" {
  description = "PostgreSQL host for pgbench"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port for pgbench"
  type        = number
  default     = 5432
}

variable "postgres_sslmode" {
  description = "PostgreSQL SSL mode"
  type        = string
  default     = "require"
}

variable "pgbench_database" {
  description = "PostgreSQL database for pgbench"
  type        = string
  default     = "pgbench"
}

variable "pgbench_user" {
  description = "PostgreSQL user for pgbench"
  type        = string
}

variable "pgbench_password" {
  description = "PostgreSQL password for pgbench"
  type        = string
  sensitive   = true
}

variable "pgbench_jobs" {
  description = "pgbench job configurations"
  type = object({
    init = object({
      enabled = bool
      scale   = number
    })
    smoke = object({
      enabled   = bool
      clients   = number
      threads   = number
      duration  = number
    })
    baseline_rw = object({
      enabled   = bool
      clients   = number
      threads   = number
      duration  = number
    })
    baseline_ro = object({
      enabled   = bool
      clients   = number
      threads   = number
      duration  = number
    })
    stress = object({
      enabled   = bool
      clients   = optional(number)
      threads   = optional(number)
      duration  = optional(number)
    })
  })
  
  default = {
    init = {
      enabled = true
      scale   = 10
    }
    smoke = {
      enabled  = false
      clients  = 4
      threads  = 2
      duration = 300
    }
    baseline_rw = {
      enabled  = false
      clients  = 5
      threads  = 2
      duration = 900
    }
    baseline_ro = {
      enabled  = false
      clients  = 10
      threads  = 4
      duration = 900
    }
    stress = {
      enabled  = false
      clients  = 100
      threads  = 16
      duration = 600
    }
  }
}
