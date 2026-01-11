packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1.7"
    }
  }
}

variable "version" {
  type    = string
  default = "v1.12.0"
}

variable "hcloud_token" {
  type      = string
  default   = env("HCLOUD_TOKEN")
  sensitive = true
}

variable "server_location" {
  type    = string
  default = "nbg1"
}

locals {
  schematic_id = jsondecode(data.http.schematic.body).id
  image_url    = "https://factory.talos.dev/image/${local.schematic_id}/${var.version}/hcloud-amd64.raw.xz"
}

data "http" "schematic" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"
  request_headers = {
    Accept = "application/json"
  }
  request_body = file("${path.root}/schematic.yaml")
}

source "hcloud" "talos" {
  token = var.hcloud_token

  image        = "debian-13"
  location     = "${var.server_location}"
  rescue       = "linux64"
  server_type  = "cx23"
  ssh_username = "root"

  snapshot_name = "talos-${var.version}-${local.schematic_id}-x86"
  snapshot_labels = {
    os      = "talos",
    version = "${var.version}"
  }
}

build {
  sources = ["source.hcloud.talos"]

  # Download the image
  provisioner "shell" {
    inline = [
      "set -ex",
      "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only -O /tmp/talos.raw.xz '${local.image_url}'",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda",
      "sync",
    ]
  }
}
