variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "domain" {
  description = "Primary domain"
  type        = string
  default     = "stargrid.systems"
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "default_location" {
  description = "Default Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}
