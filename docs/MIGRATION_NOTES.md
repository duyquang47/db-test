# Migration Notes - Terraform Project Restructuring

## What Changed

The Terraform project has been **reorganized from a simple flat layout to a standard, well-documented structure** following Terraform best practices.

### Old Structure (Deprecated)
```
main.tf                           # Combined Prometheus & MySQL/PG exporter resources + locals
addons.tf                         # pgbench runner and benchmark jobs (pg_dsm_test_addons)
benchmark_locals.tf               # Target resolution and pgbench connection logic
variables.tf                      # Input variable declarations
outputs.tf                        # Output variable declarations
provider.tf                       # Provider configuration
terraform.tfvars                  # Your configuration (sensitive!)
```

### New Structure (Recommended)
```
versions.tf                       # Terraform requirements, provider versions, backend config
provider.tf                       # (simplified) Only provider configuration
variables.tf                      # (enhanced) All input variables organized by section
locals.tf                         # (new) All computed locals in one place
monitoring.tf                     # (new) All Prometheus/Grafana/Exporter resources
load-testing.tf                   # (new) All pgbench/benchmark job resources
outputs.tf                        # (same) Output variables
terraform.tfvars.example          # (new) Configuration template with extensive comments
README.md                         # (enhanced) Full documentation and troubleshooting
QUICK_START.md                    # (new) 5-minute setup guide
STRUCTURE.md                      # (new) File organization guide
INDEX.md                          # (new) Documentation index and quick navigation
.gitignore                        # (new) Protects sensitive files (terraform.tfvars, etc)
```

## Key Improvements

### 1. **Clear File Organization**
- Resources grouped by function: `monitoring.tf` vs `load-testing.tf`
- Easier navigation and maintenance
- Industry-standard flat structure for single-environment setups

### 2. **Centralized Locals**
- All computed values in `locals.tf`
- Clear dependency chain: variables → locals → resources
- Easier debugging of target resolution logic

### 3. **Backend Configuration**
- S3/MinIO backend config moved to `versions.tf` (standard Terraform location)
- Cleaner `provider.tf` focused only on provider setup

### 4. **Enhanced Documentation**
- **QUICK_START.md**: Get running in 5 minutes
- **STRUCTURE.md**: Understanding file organization
- **INDEX.md**: Navigation guide for all docs
- **Enhanced README.md**: Comprehensive reference
- **terraform.tfvars.example**: Extensively commented template

### 5. **Git Protection**
- New `.gitignore` prevents accidental credential commits
- Protects terraform state files, kubeconfig, sensitive .tfvars

## Backward Compatibility

### ✅ Functional Compatibility
- **Same resources deployed**: Identical Helm releases, namespaces, and configurations
- **Same Kubernetes cluster changes**: No breaking changes
- **Same outputs**: All terraform outputs remain the same
- **Same state structure**: Existing `terraform.tfstate` fully compatible

### ⚠️ What Changed Internally
```
Old Location                          New Location
────────────────────────────────────────────────────────
main.tf locals block             →   locals.tf
main.tf Helm resources           →   monitoring.tf
addons.tf Helm resource          →   load-testing.tf
benchmark_locals.tf locals       →   locals.tf
provider.tf terraform block      →   versions.tf (backend only)
provider.tf helm provider        →   provider.tf (unchanged)
```

## Migration Path (If Reapplying from Scratch)

If you need to apply from scratch with new environment:

### For New Deployments (No Existing State)
Simply follow the [QUICK_START.md](./QUICK_START.md):
```bash
terraform init
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform apply
```

### For Existing Deployments (With State File)
**Option A: Keep using old structure** ✅ **RECOMMENDED**
- The old `main.tf`, `addons.tf`, `benchmark_locals.tf` still work
- Your `terraform.tfstate` remains valid
- Continue using old files - no changes needed

**Option B: Migrate to new structure** (Advanced)
- Backed up state file first: `cp terraform.tfstate terraform.tfstate.backup`
- Manually refactor old files content into new structure
- Test with `terraform plan` before applying
- This isn't automated - requires careful review

## What to Do Now

### Prerequisites
- ✅ Review new [documentation](./INDEX.md)
- ✅ Understand the [new structure](./STRUCTURE.md)

### Option 1: Existing Production Setup
- **Keep using current files**: `main.tf`, `addons.tf`, etc.
- **Your current deployment is unaffected**
- **Gradually migrate** documentation references to new docs

### Option 2: New Setup or Redesign
- **Use new structure** starting from `QUICK_START.md`
- **Copy from** `terraform.tfvars.example`
- **Follow best practices** with organized files

### Option 3: Cleanup Old Files (Optional)
If you're confident in the new structure, you can retire old files:
```bash
# Backup first!
mkdir -p old_structure_backup
mv main.tf addons.tf benchmark_locals.tf old_structure_backup/

# Keep terraform.tfstate - it's independent of file structure!
# Keep terraform.tfvars - it's your actual config
```

## Testing the New Structure

Validate that configuration is still correct:
```bash
# Syntax check
terraform validate

# See what would be deployed
terraform plan

# Should show no changes (state already matches)
# or show the expected new resources (if fresh deployment)
```

## FAQ

**Q: Will reapplying break my Kubernetes cluster?**  
A: No. The new `.tf` file structure deploys identical Kubernetes resources. Your existing deployments are unaffected.

**Q: Can I mix old and new file structures?**  
A: Not recommended. Terraform processes all `.tf` files in a directory equally. Having duplicates (e.g., `main.tf` and `monitoring.tf` with overlapping resources) would cause conflicts. Choose one approach.

**Q: What happens to my terraform.tfstate?**  
A: Unchanged. Terraform state is independent of file organization. It stores: resource types, IDs, and current values - not filenames.

**Q: Should I update my existing terraform.tfvars?**  
A: Optional. The new `terraform.tfvars.example` has better comments and new variables (like `pushgateway_image`). You can gradually migrate settings if desired.

**Q: Which documentation should I read?**  
A: Start with [INDEX.md](./INDEX.md) - it's your navigation hub. Then:
- New users → [QUICK_START.md](./QUICK_START.md)
- References → [README.md](./README.md)
- Maintenance → [STRUCTURE.md](./STRUCTURE.md)

## Support

If you encounter issues with the new structure:

1. Check [QUICK_START.md](./QUICK_START.md) or [README.md](./README.md)
2. Verify `terraform validate` passes
3. Review [STRUCTURE.md](./STRUCTURE.md) for file organization
4. Check [INDEX.md](./INDEX.md) for quick troubleshooting links

---

**Summary**: The project has been reorganized for **clarity, maintainability, and documentation**. Existing deployments remain unaffected. New users should follow the new structure and documentation starting with [QUICK_START.md](./QUICK_START.md).

**Version**: 1.0  
**Updated**: April 2026  
**Terraform**: >= 1.5.0 | **Status**: Production Ready ✅
