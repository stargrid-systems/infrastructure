# TODO: not sure if this works?
# resource "cloudflare_registrar_domain" "stargrid_systems" {
#   account_id  = var.cloudflare_account_id
#   domain_name = var.domain
#   auto_renew  = true
#   locked      = true
#   privacy     = true
# }

resource "cloudflare_zone" "stargrid_systems" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.domain
  type = "full"
}

# TODO: re-enable once it stops being pending
# resource "cloudflare_zone_dnssec" "stargrid_systems" {
#   zone_id = cloudflare_zone.stargrid_systems.id
#   dnssec_multi_signer = false
#   dnssec_presigned = true
#   dnssec_use_nsec3 = false
#   status = "active"
# }

# GitHub domain validation

resource "cloudflare_dns_record" "stargrid_systems_txt_gh" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "_gh-stargrid-systems-o"
  ttl     = 1
  type    = "TXT"
  content = "\"9649ee5b6b\""
}

# PurelyMail DNS records

resource "cloudflare_dns_record" "stargrid_systems_cname_dmarc" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "_dmarc"
  ttl     = 1
  type    = "CNAME"
  content = "dmarcroot.purelymail.com"
}

resource "cloudflare_dns_record" "stargrid_systems_cname_domainkey" {
  for_each = tomap({
    "purelymail1._domainkey" = "key1.dkimroot.purelymail.com"
    "purelymail2._domainkey" = "key2.dkimroot.purelymail.com"
    "purelymail3._domainkey" = "key3.dkimroot.purelymail.com"
  })

  zone_id = cloudflare_zone.stargrid_systems.id
  name    = each.key
  ttl     = 1
  type    = "CNAME"
  content = each.value
}

resource "cloudflare_dns_record" "stargrid_systems_mx" {
  zone_id  = cloudflare_zone.stargrid_systems.id
  name     = "@"
  ttl      = 1
  type     = "MX"
  content  = "mailserver.purelymail.com"
  priority = 0
}

resource "cloudflare_dns_record" "stargrid_systems_txt_spf" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "@"
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:_spf.purelymail.com ~all\""
}

resource "cloudflare_dns_record" "stargrid_systems_txt_purelymail_verification" {
  zone_id = cloudflare_zone.stargrid_systems.id
  name    = "@"
  ttl     = 1
  type    = "TXT"
  content = "\"purelymail_ownership_proof=d425cec1c0ada0c27b67f06253e9ac41253e153de82f0816d98320749ee44bd26815d6dfc3eca8964df49b5417137a776ec47b69357537846c8b74a54d7e3cf6\""
}
