# This snapshot is created from this repository.
# See: <flatcar-image/README.md> for more information.
data "hcloud_image" "flatcar" {
  with_selector = "os=flatcar"
  most_recent   = true
}

data "ct_config" "trappist1e" {
  content      = file("trappist-1e/ignition.yaml")
  strict       = true
  pretty_print = false
}

resource "hcloud_ssh_key" "trappist1e" {
  name       = "trappist-1e"
  public_key = file("trappist-1e/trappist-1e.pub")
}

# Firewall

resource "hcloud_firewall" "trappist1e" {
  name = "trappist-1e"

  rule {
    description = "Allow ICMP"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = toset([80, 443, 8080, 8443])
    content {
      description = "Allow Nextcloud HTTP/HTTPS"
      direction = "in"
      protocol  = "tcp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  dynamic "rule" {
    for_each = toset(["tcp", "udp"])
    content {
      description = "Allow Nextcloud Talk TCP/UDP"
      direction   = "in"
      protocol    = rule.value
      port        = 3478
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

resource "hcloud_server" "trappist1e" {
  name                     = "trappist-1e"
  server_type              = "cx33"
  image                    = data.hcloud_image.flatcar.id
  location                 = var.default_location
  user_data                = data.ct_config.trappist1e.rendered
  ssh_keys                 = [hcloud_ssh_key.trappist1e.id]
  firewall_ids             = [hcloud_firewall.trappist1e.id]
  shutdown_before_deletion = true
}

resource "cloudflare_dns_record" "trappist1e_ipv4" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "trappist-1e.private"
  content = hcloud_server.trappist1e.ipv4_address
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "trappist1e_ipv6" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = cloudflare_dns_record.trappist1e_ipv4.name
  content = hcloud_server.trappist1e.ipv6_address
  type    = "AAAA"
  ttl     = 1
}

resource "hcloud_rdns" "trappist1e_ipv4" {
  server_id  = hcloud_server.trappist1e.id
  ip_address = hcloud_server.trappist1e.ipv4_address
  dns_ptr    = cloudflare_dns_record.trappist1e_ipv4.name
}


resource "hcloud_rdns" "trappist1e_ipv6" {
  server_id  = hcloud_server.trappist1e.id
  ip_address = hcloud_server.trappist1e.ipv6_address
  dns_ptr    = cloudflare_dns_record.trappist1e_ipv4.name
}

# Nextcloud DNS record
resource "cloudflare_dns_record" "nextcloud_cname" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "nextcloud"
  content = cloudflare_dns_record.trappist1e_ipv4.name
  type    = "CNAME"
  ttl     = 1
}
