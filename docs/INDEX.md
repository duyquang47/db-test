# PostgreSQL DSM Test Stack - Documentation Index

Complete Terraform Infrastructure for Kubernetes Monitoring & PostgreSQL Load Testing

## 📚 Documentation

### For New Users
1. **[QUICK_START.md](./QUICK_START.md)** ⚡ Start here!
   - 5-minute setup guide
   - Essential configuration
   - Verify deployment
   - Common commands

2. **[README.md](./README.md)** 📖 Comprehensive guide
   - Prerequisites and architecture
   - Detailed configuration reference
   - How-to guides for common tasks
   - Troubleshooting section
   - Security best practices

### For Developers & Maintainers
3. **[STRUCTURE.md](./STRUCTURE.md)** 🏗️ Project organization
   - File-by-file guide
   - Dependencies and import chains
   - Best practices
   - Future scaling considerations

## 📁 Terraform Configuration Files

### Core Configuration
| File | Purpose |
|------|---------|
| `versions.tf` | Terraform & provider requirements, S3 backend config |
| `provider.tf` | Helm provider pointing to Kubernetes cluster |
| `variables.tf` | Input variable declarations |
| `locals.tf` | Computed local values and target resolution |
| `outputs.tf` | Export resource metadata |

### Resource Definitions
| File | Purpose |
|------|---------|
| `monitoring.tf` | Prometheus, Grafana, MySQL/PostgreSQL exporters |
| `load-testing.tf` | pgbench runner, jobs, Pushgateway, Blackbox |

### Configuration & Deployment
| File | Purpose |
|------|---------|
| `terraform.tfvars.example` | Configuration template (copy & customize) |
| `terraform.tfvars` | ⚠️ YOUR CONFIGURATION (never commit!) |
| `.gitignore` | Protects sensitive files |

### Helm Values
| File | Purpose |
|------|---------|
| `values/prometheus-stack.yaml` | Prometheus, Grafana, Alertmanager config |
| `values/prometheus-mysql-exporter.yaml` | MySQL exporter Helm values |
| `values/prometheus-postgres-exporter.yaml` | PostgreSQL exporter Helm values |

## 🚀 Quick Navigation

### I want to...

**Get started quickly**
→ Read [QUICK_START.md](./QUICK_START.md)

**Understand the full configuration**
→ Read [README.md](./README.md)

**Know how files are organized**
→ Read [STRUCTURE.md](./STRUCTURE.md)

**Configure targets and jobs**
→ Edit `terraform.tfvars` (copy from `terraform.tfvars.example`)

**Add a new PostgreSQL target**
```bash
# Edit terraform.tfvars:
postgres_targets = [
  # ... existing ...
  {
    endpoint = "new-db.example.com"
    name     = "new-target"
    # ... more fields
  }
]

# Deploy
terraform apply
```

**Enable a benchmark job**
```bash
# Edit terraform.tfvars - set pgbench_jobs.smoke.enabled = true
# Deploy
terraform apply
```

**Access Grafana**
```bash
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80
# http://localhost:3000
```

**Check monitoring status**
```bash
# Prometheus targets
kubectl port-forward -n monitoring svc/kube-prom-stack-prometheus 9090:9090
# http://localhost:9090/targets

# PostgreSQL exporter logs
kubectl logs -n monitoring -l app=prometheus-postgres-exporter -f

# Benchmark job status
kubectl get job -n loadtest
kubectl logs -n loadtest job/<job-name>
```

## 📊 Architecture Overview

```
┌─────────────────────────────────────┐
│   Your PostgreSQL/MySQL Databases   │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┬──────────────┐
    ▼                     ▼              ▼
┌─────────┐    ┌──────────────┐    ┌──────────┐
│ PG Exp. │    │ MySQL Exp.   │    │ Blackbox │
└────┬────┘    └──────┬───────┘    └────┬─────┘
     │                │                  │
     └────────────────┼──────────────────┘
                      │
              ┌───────▼────────┐
         ┌───→│  Pushgateway   │
    pgbench   │ (aggregation)  │
      jobs    └───────┬────────┘
                      │
              ┌───────▼─────────────┐
              │   Prometheus       │
              │ (metrics storage)  │
              └───────┬────────────┘
                      │
              ┌───────▼──────┐
              │    Grafana    │
              │ (dashboards) │
              └───────────────┘
```

## 🔧 Key Variables

```hcl
# Kubernetes
kubeconfig_path = "./kubeconfig"

# Monitoring targets
postgres_targets = [...]       # PostgreSQL instances to monitor
mysql_targets = [...]          # MySQL instances to monitor

# Namespaces  
monitoring_namespace = "monitoring"
loadtest_namespace   = "loadtest"

# Load testing
pgbench_enabled = true                 # Enable pgbench
pgbench_connection = {...}             # Database for testing
pgbench_jobs = {...}                   # Enable/disable jobs

# Exporters
blackbox_enabled = true                # TCP probe checks
pushgateway_enabled = true             # pgbench metrics aggregation
```

See **terraform.tfvars.example** for all variables with defaults.

## 📋 Deployment Checklist

- [ ] Prerequisites installed (Terraform >= 1.5.0, Helm, kubectl)
- [ ] S3/MinIO credentials set in environment
- [ ] Kubernetes cluster accessible via kubeconfig
- [ ] `terraform init` successful
- [ ] `terraform.tfvars` configured with your values
- [ ] `terraform plan` reviewed and confirmed
- [ ] `terraform apply` completed successfully
- [ ] Pods ready: `kubectl get pods -n monitoring`
- [ ] PostgreSQL exporter scraping: Check Prometheus targets
- [ ] Grafana accessible and dashboards visible

## 🆘 Troubleshooting

**Connection to MinIO S3 fails**
→ See [README.md - S3 Backend Connection Error](./README.md#s3-backend-connection-error)

**PostgreSQL exporter not scraping**
→ See [README.md - PostgreSQL Exporter Not Scraping](./README.md#postgresql-exporter-not-scraping)

**Blackbox probes showing DOWN**
→ See [README.md - Blackbox Probes Failing](./README.md#blackbox-probes-failing)

**pgbench jobs not running**
→ See [README.md - pgbench Jobs Not Running](./README.md#pgbench-jobs-not-running)

Full troubleshooting guide in [README.md](./README.md#troubleshooting)

## 🔐 Security Reminders

⚠️ **CRITICAL**: Never commit `terraform.tfvars` with credentials!

✅ Use `.gitignore` to protect sensitive files
✅ Store credentials in HashiCorp Vault or AWS Secrets Manager
✅ Use environment variables: `export TF_VAR_postgres_connection='...'`
✅ Rotate credentials regularly
✅ Use restrictive RBAC policies

See [README.md - Security Considerations](./README.md#security-considerations)

## 📞 Support Resources

- **Terraform Docs**: https://www.terraform.io/docs/
- **Helm Provider**: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
- **PostgreSQL Exporter**: https://github.com/prometheus-community/postgres_exporter
- **Grafana Dashboards**: https://grafana.com/grafana/dashboards/
- **pgbench Manual**: https://www.postgresql.org/docs/current/pgbench.html

## 📝 File Structure at a Glance

```
terraform-monitoring/
├── 📋 Documentation
│   ├── README.md                    # Full guide
│   ├── QUICK_START.md              # 5-minute setup
│   ├── STRUCTURE.md                # File organization
│   └── INDEX.md                    # This file
│
├── ⚙️ Terraform Core
│   ├── versions.tf                 # Versions & backend
│   ├── provider.tf                 # Kubernetes/Helm connection
│   ├── variables.tf                # Input variables
│   ├── locals.tf                   # Computed values
│   └── outputs.tf                  # Export metadata
│
├── 🔧 Resource Definitions
│   ├── monitoring.tf               # Prometheus/Grafana/Exporters
│   └── load-testing.tf             # pgbench/Pushgateway/Blackbox
│
├── 🎯 Configuration
│   ├── terraform.tfvars.example    # Template (copy this!)
│   ├── terraform.tfvars            # Your config (never commit!)
│   └── .gitignore                  # Protect sensitive files
│
├── 🎨 Helm Values
│   └── values/
│       ├── prometheus-stack.yaml
│       ├── prometheus-mysql-exporter.yaml
│       └── prometheus-postgres-exporter.yaml
│
└── 🔧 Other
    ├── kubeconfig                  # Kubernetes credentials
    ├── scripts/                    # Helper scripts
    └── .terraform/                 # Terraform working dir (git-ignored)
```

---

**Version**: 1.0  
**Last Updated**: April 2026  
**Terraform**: >= 1.5.0 | **Helm**: >= 3.x | **Kubernetes**: >= 1.24
