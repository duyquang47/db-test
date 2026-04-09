# Project Structure Guide

Terraform configuration for PostgreSQL DSM Test Stack has been reorganized for clarity and maintainability.

## File Organization

### Core Configuration Files
```
versions.tf              - Terraform & Helm provider requirements, S3 backend config
provider.tf             - Helm provider configuration pointing to Kubernetes cluster
variables.tf            - Input variable declarations (kubeconfig, targets, namespaces, etc.)
locals.tf               - Computed local values (target resolution, connection logic)
```

### Resource Definition Files
Each `.tf` file contains related resources for a specific component:

```
monitoring.tf           - Prometheus, Grafana, MySQL Exporter, PostgreSQL Exporter
load-testing.tf         - pgbench runner, benchmark jobs, Pushgateway, Blackbox Exporter
```

### Outputs & Configuration
```
outputs.tf              - Export resource metadata (release names, namespaces, targets)
terraform.tfvars.example - Configuration template (copy to terraform.tfvars and customize)
.gitignore              - Git ignore patterns (protects sensitive data)
```

### Documentation
```
README.md               - User guide and troubleshooting
STRUCTURE.md            - This file
```

## File Dependencies

### Resource Dependency Chain:
```
versions.tf (Backend config)
    ↓
provider.tf (Helm connection)
    ↓
variables.tf (Input definitions)
    ↓
locals.tf (Computed values from variables)
    ↓
├─→ monitoring.tf (Prometheus stack resources)
│       ├─→ helm_release.prometheus-stack
│       ├─→ helm_release.prometheus-mysql-exporter
│       └─→ helm_release.prometheus-postgres-exporter
│
└─→ load-testing.tf (pgbench & testing stack resources)
        └─→ helm_release.pg_dsm_test_addons (depends_on: monitoring releases)
    
    ↓
outputs.tf (References all releases for output)
```

### Local Value Dependencies (in locals.tf):
```
var.postgres_targets → local.postgres_targets → local.pgbench_target → local.pgbench_connection → local.loadtest_enabled
var.mysql_targets → local.mysql_targets
local.postgres_targets + local.mysql_targets → local.probe_targets
helm_release.prometheus-stack → local.service_monitor_labels
```

## Migration from Old Structure

### Old Layout:
```
main.tf              - Combined locals + prometheus/exporter resources
addons.tf            - pg_dsm_test_addons Helm release
benchmark_locals.tf  - pgbench connection and probe target logic
```

### New Layout:
```
locals.tf            ← Combines benchmark_locals.tf + main.tf locals
monitoring.tf        ← Prometheus/exporter resources from main.tf
load-testing.tf      ← pgbench/addons resources from addons.tf
```

**Old files (main.tf, addons.tf, benchmark_locals.tf) are now superseded.** The new `.tf` files contain the same logic in a more organized structure.

## When to Edit Each File

### Adding a New Variable
→ Edit `variables.tf`
→ Add corresponding default output if needed in `outputs.tf`

### Adding a New Kubernetes Resource
→ Create in appropriate file:
  - Monitoring-related? → `monitoring.tf`
  - Load testing? → `load-testing.tf`

### Modifying Target Resolution Logic
→ Edit `locals.tf`

### Adding Computed Values
→ Add to `locals.tf` locals block

### Changing Helm Provider Config
→ Edit `provider.tf`

### Adding Backend Configuration
→ Edit `versions.tf` backend block

## Critical Configuration Files

### terraform.tfvars (NOT in Git)
```hcl
# User-specific values - NEVER commit!
postgres_targets = [...]
pgbench_connection = {...}
# etc.
```

### terraform.tfvars.example (In Git)
```hcl
# Template with all available options
# Copy to terraform.tfvars and customize
```

### values/prometheus-stack.yaml
- Grafana ingress, dashboard provisioning settings
- Prometheus service monitor discovery configuration

### values/prometheus-mysql-exporter.yaml
- MySQL exporter-specific Helm chart values

### values/prometheus-postgres-exporter.yaml
- PostgreSQL exporter-specific Helm chart values

## Best Practices

### File Size
- Keep files < 300 lines for readability
- Group related resources together
- Use comments to separate sections

### Naming Conventions
- Variables: `lowercase_with_underscores` (e.g., `postgres_targets`)
- Locals: `lowercase_with_underscores` (e.g., `pgbench_connection_ready`)
- Resources: `resource_type.descriptive_name` (e.g., `helm_release.prometheus-stack`)

### Comments
- Every `.tf` file starts with a comment header
- Resource blocks include `# Deploy ...` comments
- Complex logic in locals explained with comments

### Imports & Dependencies
- Use `depends_on` explicitly for resource ordering
- Reference locals for computed values
- Use locals to transform input variables

## Testing File Organization

Test terraform syntax without applying:
```bash
terraform validate        # Validate all .tf files
terraform fmt -check .    # Check formatting
terraform plan            # Plan without applying
```

## Future Considerations

As the project grows, consider:

1. **Modularization** (if needs diverge)
   ```
   modules/
   ├── monitoring/
   ├── load-testing/
   └── exporters/
   ```

2. **Multi-environment** (if managing dev/staging/prod)
   ```
   environments/
   ├── dev/
   ├── staging/
   └── prod/
   ```

3. **Separate tfvars by environment**
   ```
   terraform.dev.tfvars
   terraform.staging.tfvars
   terraform.prod.tfvars
   ```

For now, the **flat structure** is optimized for single environment, rapid iteration workflows.

---
**Version**: 1.0  
**Updated**: April 2026
