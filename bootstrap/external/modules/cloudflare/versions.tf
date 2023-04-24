terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.2.0"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "kubernetes" {
  # Use KUBE_CONFIG_PATH environment variables
  # Or in cluster service account
}
