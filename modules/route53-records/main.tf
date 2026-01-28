
terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

resource "aws_route53_record" "dns_records" {
  for_each = {
    for k, v in var.records : k => v if v.alias
  }

  zone_id = var.zone_id
  name    = each.key
  type    = each.value.type

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = try(each.value.evaluate_health, false)
  }
}

resource "aws_route53_record" "standard_records" {
  for_each = {
    for k, v in var.records : k => v if !v.alias
  }

  zone_id = var.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = try(each.value.ttl, 300)

  records = [each.value.target]
}


