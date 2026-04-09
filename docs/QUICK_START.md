# Quick Start Guide

Get the PostgreSQL DSM Monitoring & Load Testing stack up and running in 5 minutes.

## 1. Prerequisites Check

```bash
# Verify tools installed
terraform -v          # >= 1.5.0
helm version          # >= 3.0
kubectl version       # >= 1.24

# Verify Kubernetes access
kubectl cluster-info
kubectl get ns
```

## 2. Set Backend Credentials

```bash
# MinIO S3 backend credentials (required for terraform init)
export AWS_ACCESS_KEY_ID="minioadmin"
export AWS_SECRET_ACCESS_KEY="minioadmin"

# Verify connectivity
curl http://171.244.195.216:9000
```

## 3. Initialize Terraform

```bash
cd terraform-monitoring

terraform init
# Output should show:
# Terraform initialized successfully!
# Backend S3 initialized
```

## 4. Configure Your Environment

```bash
# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Edit essential variables
vim terraform.tfvars
```

**Minimum required changes**:
- `kubeconfig_path`: Path to your kubeconfig (if not `./kubeconfig`)
- `postgres_targets`: Add your PostgreSQL database
- `pgbench_connection`: Add credentials for load testing (required)

**Example minimal config**:
```hcl
kubeconfig_path = "./kubeconfig"
kubeconfig_context = null

postgres_targets = [
  {
    endpoint      = "your-postgres-host.example.com"
    name          = "my-db"
    port          = 5432
    database_name = "postgres"
    user          = "exporter_user"
    password      = "exporter_password"
  }
]

pgbench_connection = {
  host     = "your-postgres-host.example.com"
  port     = 5432
  database = "benchmark_db"
  user     = "benchmark_user"
  password = "benchmark_password"
  sslmode  = "disable"
}

monitoring_namespace = "monitoring"
loadtest_namespace   = "loadtest"

# All benchmark jobs disabled by default
pgbench_jobs = {
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
```

## 5. Review and Deploy

```bash
# See what will be created
terraform plan

# Deploy (takes 2-3 minutes)
terraform apply

# Wait for resources to be ready
kubectl get pods -n monitoring -w
```

## 6. Access Grafana

```bash
# Port-forward to Grafana
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80 &

# Open in browser
# http://localhost:3000
# Username: admin
# Password: prom-operator

# Check Prometheus targets are being scraped
# Drill down: Grafana → Alerting → Prometheus
```

## 7. Verify Exporters

### PostgreSQL Exporter

```bash
# Check exporter pod is running
kubectl get pods -n monitoring -l app=prometheus-postgres-exporter

# View logs
kubectl logs -n monitoring -l app=prometheus-postgres-exporter

# Query metrics (in Prometheus UI)
# Search for: pg_stat_activity_count
```

### Blackbox Exporter (probe status)

```bash
# Check probe resources
kubectl get probe -n monitoring

# View in Grafana Prometheus Targets
# Should show: UP for TCP probes
```

## 8. (Optional) Run a Quick Benchmark

```bash
# Enable smoke test
sed -i 's/smoke.*{/smoke = {\n    enabled = true/' terraform.tfvars

# Deploy
terraform apply

# Monitor benchmark job
kubectl get job -n loadtest
kubectl logs -n loadtest job/pg-dsm-test-smoke-*

# View benchmark results in Grafana via pgbench metrics
```

## Common Commands

```bash
# View current configuration
terraform show

# Show all outputs (release info, namespaces, targets)
terraform output

# Specific outputs
terraform output namespace
terraform output postgres_exporter_release

# Check resource status
kubectl get all -n monitoring
kubectl get all -n loadtest

# Forward to Prometheus
kubectl port-forward -n monitoring svc/kube-prom-stack-prometheus 9090:9090

# View Prometheus targets
# http://localhost:9090/targets

# Port-forward to pgbench runner (for manual tests)
kubectl port-forward -n loadtest deployment/pg-dsm-test-pgbench-runner 5432:5432
```

## Cleanup

```bash
# Destroy all resources (WARNING: removes monitoring stack)
terraform destroy

# Destroy specific resource
terraform destroy -target helm_release.prometheus-stack
```

## Troubleshooting

### Terraform init fails
```bash
# Verify MinIO backend
curl http://171.244.195.216:9000
echo "Status: $?"

# Re-check credentials
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"

# Try init again
terraform init -upgrade
```

### PostgreSQL exporter not scraping
```bash
# Check connectivity
telnet your-postgres-host 5432

# View exporter logs
kubectl logs -n monitoring -l app=prometheus-postgres-exporter -f

# Verify target in Prometheus UI (http://localhost:9090/targets)
```

### Pods in Pending state
```bash
# Check node resources
kubectl describe node

# Check pod status
kubectl describe pod -n monitoring <pod-name>
kubectl describe pod -n loadtest <pod-name>
```

## Next Steps

1. **Add more database targets** → Edit `terraform.tfvars` and `terraform apply`
2. **Import curated dashboards** → Grafana Dashboard ID: 14114 (PostgreSQL), 1860 (Node), 16124 (Blackbox)
3. **Enable benchmark jobs** → Uncomment jobs in `terraform.tfvars` and run
4. **Set up alerts** → Edit `values/prometheus-stack.yaml` alerting rules
5. **Review documentation** → See `README.md` and `STRUCTURE.md`

---
**Stuck?** Check the detailed [README.md](./README.md) for full documentation and troubleshooting.
