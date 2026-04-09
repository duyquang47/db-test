# Project Structure

Clean, organized Terraform project for PostgreSQL DSM Monitoring & Load Testing.

```
terraform-monitoring/
│
├── 📚 docs/                         # Documentation (start with INDEX.md)
│   ├── INDEX.md                     # Navigation hub
│   ├── README.md                    # Full documentation
│   ├── QUICK_START.md               # 5-minute setup
│   ├── STRUCTURE.md                 # File organization
│   ├── MIGRATION_NOTES.md           # What changed from old version
│   └── 00_START_HERE.md             # Quick overview
│
├── ⚙️  Terraform Core (.tf files in root)
│   ├── versions.tf                  # Terraform & provider versions, S3 backend
│   ├── provider.tf                  # Helm provider config
│   ├── variables.tf                 # Input variable declarations
│   ├── locals.tf                    # Computed local values
│   ├── monitoring.tf                # Prometheus, Grafana, Exporters
│   ├── load-testing.tf              # pgbench, Pushgateway, Blackbox
│   ├── outputs.tf                   # Output values
│   └── .terraform.lock.hcl         # Dependency lock file (git-ignored)
│
├── 🎯 config/                       # Configuration templates & examples (CONSOLIDATED)
│   ├── README.md                    # Configuration guide
│   ├── terraform.tfvars.example     # Terraform config template (COPY THIS!)
│   ├── .gitignore.txt               # Gitignore reference
│   └── helm-values/                 # All Helm value overrides
│       ├── prometheus-stack.yaml
│       ├── prometheus-mysql-exporter.yaml
│       └── prometheus-postgres-exporter.yaml
│
├── 🎨 helm/                         # Helm charts
│   └── postgres-dsm-test-stack/     # Local custom chart
│       ├── Chart.yaml
│       ├── values.yaml              # Only main values (example removed)
│       ├── dashboards/
│       ├── templates/
│       └── README.md
│
├── 🔧 scripts/                      # Helper scripts
│   └── push-pg-auto-failover-metrics.ps1
│
├── 📄 Root Level Files
│   ├── terraform.tfvars             # YOUR CONFIGURATION (DO NOT COMMIT!)
│   ├── .gitignore                   # Git ignore rules
│   ├── kubeconfig                   # Kubernetes credentials
│   ├── terraform.tfstate            # Current state (do not commit)
│   └── terraform.tfstate.backup     # State backup
│
└── Hidden Folders (git-ignored)
    ├── .terraform/                  # Terraform working directory
    └── .terraform.lock.hcl          # Provider lock file
```

## Key Points

### 📖 Documentation
- **Start with**: `docs/INDEX.md` for navigation
- **New users**: `docs/QUICK_START.md`
- **Full reference**: `docs/README.md`
- **Project guide**: `docs/STRUCTURE.md`

### ⚙️ Terraform Config
- **All `.tf` files in ROOT** - Required by Terraform for default behavior
- **No need to specify config path** - Just run `terraform plan/apply`
- Core files are thin and focused:
  - `versions.tf`: Requirements and backend
  - `provider.tf`: Kubernetes/Helm connection
  - `variables.tf`: Input definitions
  - `locals.tf`: Computed values
  - `monitoring.tf`: Prometheus & Exporters
  - `load-testing.tf`: pgbench & Tools
  - `outputs.tf`: Export metadata

### 📋 Configuration
- **Copy**: `config/terraform.tfvars.example` → `terraform.tfvars` (root)
- **Edit**: `terraform.tfvars` with your values
- **Never commit**: `terraform.tfvars` (it's git-ignored)
- **Environment**: Set S3 credentials before init:
  ```bash
  export AWS_ACCESS_KEY_ID='...'
  export AWS_SECRET_ACCESS_KEY='...'
  terraform init
  ```

### 🎨 Helm
- **Charts** in `helm/` folder
- **Values overrides** in `values/` folder
- **Auto-provisioned** via Terraform

### 🔒 Security
- `.gitignore` protects: `.tfvars`, `kubeconfig`, `.tfstate`, credentials
- Never commit: secrets, state files, local config
- Use environment variables for credentials

## Quick Commands

```bash
# Setup
cp config/terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Prepare
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
terraform init

# Deploy
terraform plan
terraform apply

# Verify
terraform output
kubectl get pods -n monitoring
```

## File Organization Philosophy

- **Flat Terraform structure** for simplicity (all .tf in root)
- **Consolidated configuration** (all values in config/helm-values/)
- **Organized supporting files** (docs/, config/, helm/, scripts/)
- **Self-contained project** (everything needed is included)
- **Clear separation of concerns** (code / config / documentation)

See `docs/STRUCTURE.md` for detailed file relationships and dependencies.
