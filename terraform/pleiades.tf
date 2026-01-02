module "pleiades" {
  source  = "hcloud-talos/talos/hcloud"
  version = "2.21.1"

  hcloud_token = var.hcloud_token

  talos_version      = "v1.12.0"
  kubernetes_version = "1.32.4"
  cilium_version     = "1.18.5"
  hcloud_ccm_version = "v1.29.0"

  cluster_name                        = "pleiades"
  cluster_domain                      = "pleiades.internal.stargrid.systems"
  cluster_api_host                    = "kube.pleiades.internal.stargrid.systems"
  output_mode_config_cluster_endpoint = "cluster_endpoint"

  datacenter_name = "nbg1-dc3"

  control_plane_count       = 1
  control_plane_server_type = "cx23"
  disable_arm               = true
}

resource "cloudflare_dns_record" "pleiades_ipv4" {
  zone_id = cloudflare_zone.stargrid_systems.id
  type    = "A"
  name    = "kube.pleiades.internal.stargrid.systems"
  content = module.pleiades.public_ipv4_list[0]
  ttl     = 1
}
