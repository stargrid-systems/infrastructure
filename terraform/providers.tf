provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "hcloud" {
  token = var.hcloud_token
}

# Used for Hetzner Cloud S3 storage.
# See: <github.com/hetznercloud/terraform-provider-hcloud/issues/1005>.
provider "minio" {
  minio_server   = "${var.default_location}.your-objectstorage.com"
  minio_user     = var.hcloud_s3_access_key
  minio_password = var.hcloud_s3_secret_key
  minio_region   = var.default_location
  minio_ssl      = true
}
