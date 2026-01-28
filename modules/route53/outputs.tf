output "certificate_arn" {
  value = aws_acm_certificate_validation.cert.certificate_arn
}

output "domain_name" {
  value = var.domain_name
}

output "zone_id" {
  value = aws_route53_zone.hosted_zone.zone_id
}
