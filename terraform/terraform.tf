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
}
