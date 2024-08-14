data "cloudflare_zone" "zone" {
  name = var.cluster_domainname
}

data "cloudflare_api_token_permission_groups" "all" {}

data "http" "public_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

# data "http" "public_ipv6" {
#   url = "https://ipv6.icanhazip.com"
# }

locals {
  public_ips = [
    "${chomp(data.http.public_ipv4.body)}/32",
    # "${chomp(data.http.public_ipv6.body)}/128"
  ]
}

resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_argo_tunnel" "homelab" {
  account_id = var.cloudflare_account_id
  name       = "homelab"
  secret     = base64encode(random_password.tunnel_secret.result)
}

# Not proxied, not accessible. Just a record for auto-created CNAMEs by external-dns.
resource "cloudflare_record" "tunnel" {
  count = var.freenomdomain ? 0 : 1

  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "homelab-tunnel"
  value   = "${cloudflare_argo_tunnel.homelab.id}.cfargotunnel.com"
  proxied = false
  ttl     = 1 # Auto
}

resource "cloudflare_record" "freenom_tunnel" {
  count = var.freenomdomain ? 1 : 0

  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "*"
  value   = "${cloudflare_argo_tunnel.homelab.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1 # Auto
}


resource "kubernetes_secret" "cloudflared_credentials" {
  metadata {
    name      = "cloudflared-credentials"
    namespace = "cloudflared"
  }

  data = {
    "credentials.json" = jsonencode({
      AccountTag   = var.cloudflare_account_id
      TunnelName   = cloudflare_argo_tunnel.homelab.name
      TunnelID     = cloudflare_argo_tunnel.homelab.id
      TunnelSecret = base64encode(random_password.tunnel_secret.result)
    })
  }
}

resource "cloudflare_api_token" "external_dns" {
  count = var.freenomdomain ? 0 : 1
  name  = "homelab_external_dns"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  # condition {
  #   request_ip {
  #     in = local.public_ips
  #   }
  # }
}

resource "kubernetes_secret" "external_dns_token" {
  count = var.freenomdomain ? 0 : 1
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }

  data = {
    "value" = cloudflare_api_token.external_dns.0.value
  }
}

resource "cloudflare_api_token" "cert_manager" {
  count = var.freenomdomain ? 0 : 1
  name  = "homelab_cert_manager"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  # condition {
  #   request_ip {
  #     in = local.public_ips
  #   }
  # }
}

resource "kubernetes_secret" "cert_manager_token" {
  count = var.freenomdomain ? 0 : 1
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = cloudflare_api_token.cert_manager.0.value
  }
}
