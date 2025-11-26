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
    for_each = toset([80, 8443])
    content {
      description = "Allow Nextcloud AIO"
      direction   = "in"
      protocol    = "tcp"
      port        = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  dynamic "rule" {
    for_each = toset(["tcp", "udp"])
    content {
      description = "Allow Nextcloud"
      direction   = "in"
      protocol    = rule.value
      port        = 443
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  dynamic "rule" {
    for_each = toset(["tcp", "udp"])
    content {
      description = "Allow Nextcloud Talk Turnserver"
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

# This snapshot is created from this repository.
# See: <flatcar-image/README.md> for more information.
data "hcloud_image" "flatcar" {
  with_selector = "os=flatcar"
  most_recent   = true
}

data "ct_config" "trappist1e" {
  content      = file("trappist-1e/base.yaml")
  strict       = true
  pretty_print = false

  snippets = [
    templatefile("trappist-1e/ephemeral1-filesystem.yaml.tftpl", {
      volume_linux_device = hcloud_volume.trappist1e.linux_device,
    }),
    file("trappist-1e/docker-mount.yaml"),
  ]
}

resource "hcloud_ssh_key" "trappist1e" {
  name       = "trappist-1e"
  public_key = file("trappist-1e/trappist-1e.pub")
}

# Nextcloud data volume
resource "hcloud_volume" "trappist1e" {
  name = "trappist-1e"
  size = 128
  # We can't attach the volume directly to avoid a cylce.
  location = var.default_location
  format   = "ext4"
}

# Server

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

# Attach the volume
resource "hcloud_volume_attachment" "trappist1e" {
  server_id = hcloud_server.trappist1e.id
  volume_id = hcloud_volume.trappist1e.id
  automount = false
}


# RDNS and DNS records

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
