################################################################################
# Load Testing Module
# Helm releases: Pushgateway, Blackbox Exporter
# Kubernetes resources: pgbench Jobs
################################################################################

# Create loadtest namespace
resource "kubernetes_namespace_v1" "loadtest" {
  count = var.create_loadtest_namespace ? 1 : 0

  metadata {
    name = var.loadtest_namespace
    labels = {
      "app"         = "load-testing"
      "managed-by"  = "terraform"
    }
  }
}

# Pushgateway Helm Release
resource "helm_release" "pushgateway" {
  count           = var.pushgateway_enabled ? 1 : 0
  name            = "pushgateway"
  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "prometheus-pushgateway"
  namespace       = var.loadtest_namespace
  create_namespace = false
  upgrade_install = true
  version         = var.pushgateway_chart_version

  values = [file("${path.module}/../../config/helm-values/pushgateway.yaml")]

  depends_on = [kubernetes_namespace_v1.loadtest]
}

# Blackbox Exporter Helm Release
resource "helm_release" "blackbox_exporter" {
  count           = var.blackbox_enabled ? 1 : 0
  name            = "blackbox-exporter"
  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "prometheus-blackbox-exporter"
  namespace       = var.loadtest_namespace
  create_namespace = false
  upgrade_install = true
  version         = var.blackbox_exporter_chart_version

  values = [file("${path.module}/../../config/helm-values/blackbox-exporter.yaml")]

  depends_on = [kubernetes_namespace_v1.loadtest]
}

# pgbench Init Job
resource "kubernetes_job_v1" "pgbench_init" {
  count = var.pgbench_enabled && var.pgbench_jobs.init.enabled ? 1 : 0

  metadata {
    name      = "pgbench-init"
    namespace = var.loadtest_namespace
    labels = {
      app      = "pgbench"
      job-type = "init"
    }
  }

  spec {
    ttl_seconds_after_finished = 86400
    backoff_limit              = 1

    template {
      metadata {
        labels = {
          app      = "pgbench"
          job-type = "init"
        }
      }

      spec {
        restart_policy = "Never"
        container {
          name  = "pgbench"
          image = var.pgbench_image

          env {
            name  = "PGHOST"
            value = var.postgres_host
          }
          env {
            name  = "PGPORT"
            value = tostring(var.postgres_port)
          }
          env {
            name  = "PGDATABASE"
            value = var.pgbench_database
          }
          env {
            name  = "PGUSER"
            value = var.pgbench_user
          }
          env {
            name  = "PGPASSWORD"
            value = var.pgbench_password
          }
          env {
            name  = "PGSSLMODE"
            value = var.postgres_sslmode
          }

          command = ["pgbench"]
          args = [
            "-i",
            "-s", tostring(var.pgbench_jobs.init.scale),
            var.pgbench_database
          ]

          resources {
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.loadtest]
}

# pgbench Smoke Test Job
resource "kubernetes_job_v1" "pgbench_smoke" {
  count = var.pgbench_enabled && var.pgbench_jobs.smoke.enabled ? 1 : 0

  metadata {
    name      = "pgbench-smoke"
    namespace = var.loadtest_namespace
    labels = {
      app      = "pgbench"
      job-type = "smoke"
    }
  }

  spec {
    ttl_seconds_after_finished = 86400
    backoff_limit              = 1

    template {
      metadata {
        labels = {
          app      = "pgbench"
          job-type = "smoke"
        }
      }

      spec {
        restart_policy = "Never"
        container {
          name  = "pgbench"
          image = var.pgbench_image

          env {
            name  = "PGHOST"
            value = var.postgres_host
          }
          env {
            name  = "PGPORT"
            value = tostring(var.postgres_port)
          }
          env {
            name  = "PGDATABASE"
            value = var.pgbench_database
          }
          env {
            name  = "PGUSER"
            value = var.pgbench_user
          }
          env {
            name  = "PGPASSWORD"
            value = var.pgbench_password
          }
          env {
            name  = "PGSSLMODE"
            value = var.postgres_sslmode
          }

          command = ["pgbench"]
          args = [
            "-c", tostring(var.pgbench_jobs.smoke.clients),
            "-j", tostring(var.pgbench_jobs.smoke.threads),
            "-T", tostring(var.pgbench_jobs.smoke.duration),
            "-r",
            var.pgbench_database
          ]

          resources {
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.loadtest, kubernetes_job_v1.pgbench_init]
}

# pgbench Baseline RW Job
resource "kubernetes_job_v1" "pgbench_baseline_rw" {
  count = var.pgbench_enabled && var.pgbench_jobs.baseline_rw.enabled ? 1 : 0

  metadata {
    name      = "pgbench-baseline-rw"
    namespace = var.loadtest_namespace
    labels = {
      app      = "pgbench"
      job-type = "baseline-rw"
    }
  }

  spec {
    ttl_seconds_after_finished = 86400
    backoff_limit              = 1

    template {
      metadata {
        labels = {
          app      = "pgbench"
          job-type = "baseline-rw"
        }
      }

      spec {
        restart_policy = "Never"
        container {
          name  = "pgbench"
          image = var.pgbench_image

          env {
            name  = "PGHOST"
            value = var.postgres_host
          }
          env {
            name  = "PGPORT"
            value = tostring(var.postgres_port)
          }
          env {
            name  = "PGDATABASE"
            value = var.pgbench_database
          }
          env {
            name  = "PGUSER"
            value = var.pgbench_user
          }
          env {
            name  = "PGPASSWORD"
            value = var.pgbench_password
          }
          env {
            name  = "PGSSLMODE"
            value = var.postgres_sslmode
          }

          command = ["pgbench"]
          args = [
            "-c", tostring(var.pgbench_jobs.baseline_rw.clients),
            "-j", tostring(var.pgbench_jobs.baseline_rw.threads),
            "-T", tostring(var.pgbench_jobs.baseline_rw.duration),
            "-r",
            var.pgbench_database
          ]

          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.loadtest, kubernetes_job_v1.pgbench_init]
}

# pgbench Stress Test Job
resource "kubernetes_job_v1" "pgbench_stress" {
  count = var.pgbench_enabled && var.pgbench_jobs.stress.enabled ? 1 : 0

  metadata {
    name      = "pgbench-stress"
    namespace = var.loadtest_namespace
    labels = {
      app      = "pgbench"
      job-type = "stress"
    }
  }

  spec {
    ttl_seconds_after_finished = 86400
    backoff_limit              = 1

    template {
      metadata {
        labels = {
          app      = "pgbench"
          job-type = "stress"
        }
      }

      spec {
        restart_policy = "Never"
        container {
          name  = "pgbench"
          image = var.pgbench_image

          env {
            name  = "PGHOST"
            value = var.postgres_host
          }
          env {
            name  = "PGPORT"
            value = tostring(var.postgres_port)
          }
          env {
            name  = "PGDATABASE"
            value = var.pgbench_database
          }
          env {
            name  = "PGUSER"
            value = var.pgbench_user
          }
          env {
            name  = "PGPASSWORD"
            value = var.pgbench_password
          }
          env {
            name  = "PGSSLMODE"
            value = var.postgres_sslmode
          }

          command = ["pgbench"]
          args = [
            "-c", tostring(var.pgbench_jobs.stress.clients),
            "-j", tostring(var.pgbench_jobs.stress.threads),
            "-T", tostring(var.pgbench_jobs.stress.duration),
            "-r",
            var.pgbench_database
          ]

          resources {
            requests = {
              cpu    = "1"
              memory = "1Gi"
            }
            limits = {
              cpu    = "4"
              memory = "4Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace_v1.loadtest, kubernetes_job_v1.pgbench_init]
}
