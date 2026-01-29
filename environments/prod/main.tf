module "dns" {
  source      = "../../modules/route53"
  domain_name = "pragma-ev.com"
  tags        = local.tags
}

module "dns_records" {
  source  = "../../modules/route53-records"
  zone_id = module.dns.zone_id

  records = local.records
}


module "s3_frontend" {
  source          = "../../modules/s3-frontend"
  project         = var.project
  environment     = var.environment
  index_document  = "index.html"
  error_document  = "error.html"
  log_bucket_name = "buckets-pragma-logs"
  tags            = local.tags
}

module "cloudfront_frontend" {
  depends_on      = [module.s3_frontend, module.dns]
  source          = "../../modules/cloudfront-oac"
  project         = var.project
  environment     = var.environment
  s3_bucket_arn   = module.s3_frontend.bucket_arn
  s3_bucket_id    = module.s3_frontend.bucket_name
  log_bucket_name = "buckets-pragma-logs"

  acm_certificate_arn = module.dns.certificate_arn
  domain_name         = "www.${module.dns.domain_name}"
  tags                = local.tags
}


module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment

  vpc_cidr_block               = "172.16.0.0/21"
  subnet_private_1a_cidr_block = "172.16.0.0/23"
  subnet_private_1b_cidr_block = "172.16.2.0/23"
  subnet_private_1c_cidr_block = "172.16.4.0/23"
  subnet_public_1a_cidr_block  = "172.16.6.0/25"
  subnet_public_1b_cidr_block  = "172.16.6.128/25"
  subnet_public_1c_cidr_block  = "172.16.7.0/25"

  region = var.region

  tags = local.tags
}
