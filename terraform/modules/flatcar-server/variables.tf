variable "server_type" {
  description = "The type of Hetzner server to create."
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "The Hetzner location to create the server in."
  type        = string
}

variable "ignition_config" {
  description = "The Ignition config to use for the Flatcar server."
  type        = string
}

variable "ipv4_enabled" {
  description = "Whether to enable IPv4 on the server."
  type        = bool
  default     = false
}

variable "fqdn" {
  description = "The fully qualified domain name for the server."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID for DNS records."
  type        = string
}
