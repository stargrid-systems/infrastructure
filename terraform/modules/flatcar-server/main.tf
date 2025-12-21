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
      version = "~> 1.57"
    }
  }
}

locals {
  hostname = split(".", var.fqdn)[0]
}

# This snapshot is created from this repository.
# See: <flatcar-image/README.md> for more information.
data "hcloud_image" "flatcar" {
  with_selector = "os=flatcar"
  most_recent   = true
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "this" {
  name       = local.hostname
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "hcloud_server" "this" {
  name                     = local.hostname
  server_type              = var.server_type
  image                    = data.hcloud_image.flatcar.id
  location                 = var.location
  ssh_keys                 = [hcloud_ssh_key.this.id]
  user_data                = var.ignition_config
  shutdown_before_deletion = true

  public_net {
    ipv4_enabled = var.ipv4_enabled
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [
      # Flatcar automatically updates itself.
      image,
    ]
  }
}

# RDNS and DNS records

resource "cloudflare_dns_record" "ipv4" {
  count = var.ipv4_enabled ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = var.fqdn
  content = hcloud_server.this.ipv4_address
  type    = "A"
  ttl     = 1
}

resource "hcloud_rdns" "ipv4" {
  count = var.ipv4_enabled ? 1 : 0

  server_id  = hcloud_server.this.id
  ip_address = hcloud_server.this.ipv4_address
  dns_ptr    = var.fqdn
}

resource "cloudflare_dns_record" "ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = var.fqdn
  content = hcloud_server.this.ipv6_address
  type    = "AAAA"
  ttl     = 1
}

resource "hcloud_rdns" "ipv6" {
  server_id  = hcloud_server.this.id
  ip_address = hcloud_server.this.ipv6_address
  dns_ptr    = var.fqdn
}
