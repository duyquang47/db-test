terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }

  # Backend configuration - commented for local testing
  # Uncomment when AWS credentials available
  # backend "s3" {
  #   bucket = "terraform-state"
  #   key    = "env/dev/postgres-dsm-test-stack/terraform.tfstate"
  #   region = "us-east-1"
  #   endpoints = {
  #     s3 = "http://171.244.195.216:9000"
  #   }
  #   use_path_style              = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   skip_metadata_api_check     = true
  #   skip_s3_checksum            = true
  #   use_lockfile                = true
  # }
}
