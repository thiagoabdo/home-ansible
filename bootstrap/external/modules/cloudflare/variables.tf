variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}

variable "freenomdomain" {
  type = bool
  default = false
}

variable "cluster_domainname" {
  type = string
}