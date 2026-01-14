# This snapshot is created from this repository.
# See: <packer/talos/README.md> for more information.
data "hcloud_image" "talos" {
  with_selector = "os=talos"
  most_recent   = true
}

resource "hcloud_firewall" "pleiades" {
  name = "pleiades"

  rule {
    description = "Allow traffic to Kubernetes API server"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Allow traffic to Talos API"
    direction   = "in"
    protocol    = "tcp"
    port        = "50000"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Allow traffic to HTTP"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = ["tcp", "udp"]
    content {
      description = "Allow traffic to HTTPS"
      direction   = "in"
      protocol    = rule.value
      port        = "443"
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

resource "hcloud_server" "pleiades_c1" {
  name        = "pleiades-c1"
  server_type = "cx23"
  image       = data.hcloud_image.talos.id
  location    = var.default_location
  ssh_keys    = []
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  firewall_ids = [hcloud_firewall.pleiades.id]


  lifecycle {
    ignore_changes = [
      # Talos is self-updating
      image
    ]
  }
}

resource "cloudflare_dns_record" "pleiades_ipv4" {
  zone_id = cloudflare_zone.stargrid_systems.id
  type    = "A"
  name    = "kube.pleiades.stargrid.systems"
  content = hcloud_server.pleiades_c1.ipv4_address
  ttl     = 60
}

resource "cloudflare_dns_record" "pleiades_ipv6" {
  zone_id = cloudflare_zone.stargrid_systems.id
  type    = "AAAA"
  name    = "kube.pleiades.stargrid.systems"
  content = hcloud_server.pleiades_c1.ipv6_address
  ttl     = 60
}
