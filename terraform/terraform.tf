terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.13"
    }

    ct = {
      source  = "poseidon/ct"
      version = "~> 0.14"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.56"
    }

    # Used for Hetzner Cloud S3 storage.
    # See: <github.com/hetznercloud/terraform-provider-hcloud/issues/1005>.
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.3"
    }
  }

  backend "s3" {
    key = "infrastructure/terraform.tfstate"
    use_lockfile = true

    endpoints = {
      s3 = "https://nbg1.your-objectstorage.com"
    }
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
  }
}
