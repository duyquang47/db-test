# Helm chart: PostgreSQL DSM Test Stack

This chart deploys the addon resources needed for the latest PostgreSQL DSM performance test plan, assuming an existing Prometheus/Grafana monitoring stack already exists.

It deploys:

- `blackbox-exporter`
- `Probe` resources
- `Pushgateway`
- Grafana dashboard ConfigMap
- `pgbench` runner
- optional `pgbench` Jobs
- DSM DB cluster OS metrics collector

## 1. Prepare values

Copy `values.example.yaml` to a working file, for example `values.local.yaml`, then update:

- `testProfile`
- `namespaceManagement`
- `postgres.host`
- `postgres.benchmarkDatabase`
- `postgres.pgbenchUser`
- `postgres.pgbenchPassword`

Example:

```powershell
Copy-Item .\helm\postgres-dsm-test-stack\values.example.yaml .\helm\postgres-dsm-test-stack\values.local.yaml
```

Available `testProfile` presets:

- `2c2g`
- `2c4g`
- `2c8g`

The profile fills in default concurrency, threads, and duration for:

- smoke
- baseline RW
- baseline RO
- ramp-up
- data sweep 10M
- data sweep 20M
- stress
- HA observation
- soak

You can still override any specific job value under `.Values.jobs`.

## 2. Install or upgrade

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring --create-namespace -f .\helm\postgres-dsm-test-stack\values.local.yaml
```

## 3. Check resources

```powershell
kubectl get pods -n monitoring
kubectl get pods -n loadtest
```

## 4. Access Grafana

```powershell
kubectl -n monitoring port-forward svc/pg-dsm-test-grafana 3000:3000
```

## 5. Run pgbench jobs

All jobs are disabled by default. Enable one scenario at a time with `helm upgrade --install`.

Initialize the baseline dataset (`scale=10`):

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.init.enabled=true
```

Smoke:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.smoke.enabled=true
```

Baseline RW:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.baselineRw.enabled=true
```

Baseline RO:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.baselineRo.enabled=true
```

Ramp-up:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.ramp.enabled=true
```

Data sweep 10M (`scale=100`):

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.dataSweep10m.enabled=true
```

Data sweep 20M (`scale=200`):

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.dataSweep20m.enabled=true
```

Stress:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.stress.enabled=true
```

HA observation:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.haObservation.enabled=true
```

Soak:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set jobs.soak.enabled=true
```

Example: switch to the `2c8g` profile and run a 20M data sweep without reinitializing the dataset:

```powershell
helm upgrade --install pg-dsm-test .\helm\postgres-dsm-test-stack -n monitoring -f .\helm\postgres-dsm-test-stack\values.local.yaml --set testProfile=2c8g --set jobs.dataSweep20m.enabled=true --set jobs.dataSweep20m.reinitialize=false
```

## 6. Cleanup jobs

```powershell
kubectl delete job -n loadtest pg-dsm-test-init
kubectl delete job -n loadtest pg-dsm-test-smoke
kubectl delete job -n loadtest pg-dsm-test-baseline-rw
kubectl delete job -n loadtest pg-dsm-test-baseline-ro
kubectl delete job -n loadtest pg-dsm-test-ramp
kubectl delete job -n loadtest pg-dsm-test-data-sweep-10m
kubectl delete job -n loadtest pg-dsm-test-data-sweep-20m
kubectl delete job -n loadtest pg-dsm-test-stress
kubectl delete job -n loadtest pg-dsm-test-ha-observation
kubectl delete job -n loadtest pg-dsm-test-soak
```

## Notes

- The chart manages resources in both `monitoring` and `loadtest`.
- In addon mode, disable `prometheus`, `grafana`, and `postgresExporter`, then let the existing monitoring stack scrape the `blackbox-exporter` and `Probe` resources from this chart.
- Installing the chart does not create or change any DSM resource.
- Enabling `pgbench` jobs or running `pgbench -i` will modify the target benchmark database.
- `dataSweep10m` and `dataSweep20m` reinitialize the benchmark schema by default with `pgbench -i -I dtgvp`.
- `haObservation` only opens the workload window. The actual failover or maintenance action must be triggered externally in DSM or by the platform team.
- Use a dedicated benchmark database only. Do not point this chart to a production schema.
