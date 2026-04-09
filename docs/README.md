# PostgreSQL DSM Test Stack - Terraform Configuration

Terraform Infrastructure as Code for deploying a comprehensive **Kubernetes monitoring and PostgreSQL load testing stack** using Helm charts. Includes Prometheus, Grafana, database exporters, blackbox probes, and pgbench load testing tools.

## Project Structure

```
terraform-monitoring/
├── versions.tf                      # Terraform & provider versions, S3 backend config
├── variables.tf                     # Input variable declarations
├── locals.tf                        # Computed local values
├── provider.tf                      # Helm provider configuration
├── monitoring.tf                    # Prometheus, Grafana, MySQL/PostgreSQL exporters
├── load-testing.tf                  # pgbench runner, benchmark jobs, pushgateway, blackbox
├── outputs.tf                       # Export resource metadata
├── terraform.tfvars.example         # Configuration template (copy to terraform.tfvars)
└── values/                          # Helm chart value overrides
    ├── prometheus-stack.yaml        # Prometheus/Grafana/Alertmanager config
    ├── prometheus-mysql-exporter.yaml
    └── prometheus-postgres-exporter.yaml
```

## What It Deploys

### Monitoring Stack (kube-prometheus-stack)
- **Prometheus**: Metrics scraping and time-series storage
- **Grafana**: Dashboards and visualization (with Ingress support)
- **Node Exporter**: Kubernetes node metrics
- **AlertManager**: Alert aggregation (disabled by default)

### Database Exporters
- **MySQL Exporter**: Multi-target monitoring with configurable credentials
- **PostgreSQL Exporter**: Multi-target monitoring with authentication modules

### Load Testing Stack (pg-dsm-test-addons)
- **Blackbox Exporter**: TCP/ICMP endpoint availability probes
- **Pushgateway**: Metrics aggregation for pgbench jobs
- **pgbench Runner**: Long-running benchmark executor deployment
- **Benchmark Jobs**: Kubernetes Jobs for predefined test scenarios:
  - `init`: Database initialization
  - `smoke`: Verification test
  - `baseline_rw`, `baseline_ro`: Baseline performance tests
  - `ramp`: Gradual load increase
  - `data_sweep_10m`, `data_sweep_20m`: Large dataset scans
  - `stress`: Maximum load testing
  - `ha_observation`: High availability monitoring
  - `soak`: Sustained load testing

### Grafana Dashboard Provisioning
- Custom PostgreSQL performance dashboard via ConfigMap sidecar

## Prerequisites

### Tools
- **Terraform** >= 1.5.0
- **Helm** >= 3.x
- **kubectl** >= 1.24

### Infrastructure
- Kubernetes cluster (EKS, AKS, on-prem, etc.)
- Valid kubeconfig file (default: `./kubeconfig`)
- RBAC permissions for namespace and resource creation

### Backend Storage
- S3/MinIO bucket: `terraform-state`
- MinIO endpoint: `http://171.244.195.216:9000`
- Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

## Quick Start

### 1. Initialize Backend

```bash
cd terraform-monitoring

# Set S3 credentials
export AWS_ACCESS_KEY_ID="minioadmin"
export AWS_SECRET_ACCESS_KEY="minioadmin"

# Initialize Terraform
terraform init
```

### 2. Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your environment
vim terraform.tfvars
```

**Key settings**:
- `postgres_targets`: List of PostgreSQL databases to monitor
- `mysql_targets`: List of MySQL databases (optional)
- `kubeconfig_path`: Path to your kubeconfig
- `pgbench_connection`: Database credentials for load testing
- `pgbench_jobs`: Enable/disable benchmark jobs

### 3. Plan and Deploy

```bash
# Review changes
terraform plan

# Deploy the stack
terraform apply
```

### 4. Access Grafana

```bash
# Port-forward to Grafana
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80

# Access at: http://localhost:3000
# Default credentials: admin / prom-operator
```

## Important Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `postgres_targets` | list(object) | `[]` | PostgreSQL endpoints for monitoring |
| `mysql_targets` | list(object) | `[]` | MySQL endpoints for monitoring |
| `monitoring_namespace` | string | `monitoring` | Namespace for monitoring stack |
| `loadtest_namespace` | string | `loadtest` | Namespace for load testing |
| `blackbox_enabled` | bool | `true` | Deploy blackbox exporter |
| `pushgateway_enabled` | bool | `true` | Deploy pushgateway |
| `pgbench_enabled` | bool | `true` | Enable pgbench runner & jobs |
| `pgbench_connection` | object | `null` | Database connection for pgbench (REQUIRED if pgbench_enabled) |
| `test_profile` | string | `2c4g` | Benchmark profile (2c2g, 2c4g, 2c8g) |
| `pgbench_jobs` | object | All disabled | Benchmark job configurations |

## Benchmark Profiles

Preset concurrency and duration for different DB sizes:

### 2c2g (2 CPU, 2GB RAM)
- Light workload: 4-8 clients

### 2c4g (2 CPU, 4GB RAM) - **DEFAULT**
- Medium workload: 8-16 clients

### 2c8g (2 CPU, 8GB RAM)
- Heavy workload: 16-32 clients

Profiles control defaults for: smoke, baseline_rw, baseline_ro, ramp, data_sweep_10m, data_sweep_20m, stress, ha_observation, soak

## Benchmark Jobs

All jobs are **disabled by default**. Enable selectively in `terraform.tfvars`:

```hcl
pgbench_jobs = {
  init = {
    enabled = true
    scale   = 10              # Scale factor
  }
  smoke = {
    enabled = true
    clients = 4               # Optional: override profile default
    threads = 1
    duration = 60             # Seconds
  }
  baseline_rw = {
    enabled = true
    clients  = 20
    threads  = 4
    duration = 300
  }
  # ... more jobs
}
```

## Outputs

```bash
# View all outputs
terraform output

# Specific outputs
terraform output namespace                  # Monitoring namespace
terraform output prometheus_stack_release   # Prometheus release info
terraform output pgbench_runner             # pgbench deployment details
terraform output blackbox_exporter          # Blackbox targets list
terraform output pgbench_enabled_jobs       # List of active benchmark jobs
```

## Dashboard Recommendations

Import these Grafana dashboards:
- **PostgreSQL Exporter**: Grafana ID `14114` or `12273`
- **Node Exporter**: Grafana ID `1860`
- **Blackbox Exporter**: Grafana ID `16124`
- **Custom Dashboard**: Auto-provisioned from ConfigMap

## Common Tasks

### Add a PostgreSQL Target

```hcl
# In terraform.tfvars
postgres_targets = [
  {
    endpoint      = "db.example.com"
    name          = "production"
    port          = 5432
    database_name = "postgres"
    user          = "exporter_user"     # Optional
    password      = "password"          # Optional
  }
]
```

### Run a Benchmark Job

```hcl
# Enable smoke test in terraform.tfvars
pgbench_jobs = {
  smoke = {
    enabled  = true
    clients  = 8
    threads  = 2
    duration = 120
  }
  # ... disable other jobs
}

terraform apply
```

### Monitor Exporter Status

```bash
# Check PostgreSQL exporter logs
kubectl logs -n monitoring -l app=prometheus-postgres-exporter -f

# Verify metrics are being scraped
kubectl port-forward -n monitoring svc/kube-prom-stack-prometheus 9090:9090
# Access http://localhost:9090 and search for pg_* metrics

# Check ServiceMonitor status
kubectl get servicemonitor -n monitoring
kubectl describe servicemonitor -n monitoring prom-postgres-exporter
```

### Run Manual Load Test

```bash
# Interactive pgbench
kubectl exec -it -n loadtest deployment/pg-dsm-test-pgbench-runner -- bash

# Inside pod:
pgbench -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE \
  -c 20 -j 4 -T 300
```

## Troubleshooting

### S3 Backend Connection Error

```bash
# Verify MinIO endpoint
curl http://171.244.195.216:9000

# Set credentials
export AWS_ACCESS_KEY_ID="minioadmin"
export AWS_SECRET_ACCESS_KEY="minioadmin"

# Retry init
terraform init
```

### PostgreSQL Exporter Not Scraping

**Check connectivity**:
```bash
telnet <postgres_endpoint> 5432
```

**Review exporter config**:
```bash
kubectl describe configmap -n monitoring prom-postgres-exporter
kubectl logs -n monitoring -l app=prometheus-postgres-exporter
```

**Verify ServiceMonitor**:
```bash
kubectl get servicemonitor -n monitoring
kubectl get endpoints -n monitoring
```

### Blackbox Probes Failing

```bash
# Check probe resources
kubectl get probe -n monitoring
kubectl describe probe -n monitoring

# Manual probe test
kubectl exec -it -n monitoring -l app=blackbox-exporter \
  -- /bin/blackbox_exporter --version
```

### pgbench Jobs Not Running

**Common causes**:
- Missing `pgbench_connection` credentials
- `loadtest_namespace` creation failed
- Node resource quotas exceeded

**Debug**:
```bash
kubectl describe job -n loadtest
kubectl logs -n loadtest <job-name-pod>
```

## Security Notes

⚠️ **Never commit `terraform.tfvars` with credentials!**

**Best Practices**:
1. Add to `.gitignore`: `terraform.tfvars`
2. Use environment variables: `export TF_VAR_pgbench_connection='...'`
3. Store secrets in HashiCorp Vault or AWS Secrets Manager
4. Rotate credentials regularly
5. Restrict RBAC permissions

## Maintenance

### Backup State

```bash
# Manual backup
cp terraform.tfstate terraform.tfstate.backup

# S3 versioning should be enabled in MinIO bucket
```

### Update Charts

```bash
# Update Helm repositories
helm repo update

# Terraform will use updated charts on next apply
```

### Destroy Stack

```bash
# WARNING: Removes all monitoring and testing components
terraform destroy
```

## Notes

- `postgres_targets` and `mysql_targets` are for exporters only, not load testing
- `pgbench` requires `pgbench_connection` with valid credentials
- All benchmark jobs disabled by default (enable selectively)
- `pgbench_jobs` supports per-job parameter overrides
- Blackbox probes created automatically for all targets (when enabled)
- Grafana dashboard sidecar discovery enabled (searches all namespaces)
- pgbench metrics pushed to Pushgateway and scraped under `pgbench_*` metric family
- For HA failover testing, use `scripts/push-pg-auto-failover-metrics.ps1` to publish failover events

## Resources

- [Terraform Docs](https://www.terraform.io/docs/)
- [Helm Terraform Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts)
- [PostgreSQL Exporter](https://github.com/prometheus-community/postgres_exporter)
- [pgbench Manual](https://www.postgresql.org/docs/current/pgbench.html)

---

**Last Updated**: April 2026 | **Terraform**: >= 1.5.0 | **Helm**: >= 3.x
