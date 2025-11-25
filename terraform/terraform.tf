terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.56"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.13"
    }

    ct = {
      source  = "poseidon/ct"
      version = "~> 0.14"
    }
  }
}
