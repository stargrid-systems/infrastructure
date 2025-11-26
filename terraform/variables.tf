# Credentials
variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "hcloud_s3_access_key" {
  description = "Hetzner Cloud S3 access key"
  type        = string
  sensitive   = true
}

variable "hcloud_s3_secret_key" {
  description = "Hetzner Cloud S3 secret key"
  type        = string
  sensitive   = true
}

# Config

variable "domain" {
  description = "Primary domain"
  type        = string
  default     = "stargrid.systems"
}

variable "default_location" {
  description = "Default Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}
