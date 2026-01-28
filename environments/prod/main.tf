module "s3_frontend" {
  source          = "../../modules/s3-frontend"
  project         = var.project
  environment     = var.environment
  index_document  = "index.html"
  error_document  = "error.html"
  log_bucket_name = "buckets-pragma-logs"
  tags            = local.tags
}

module "cloudfront" {
  depends_on      = [module.s3_frontend]
  source          = "../../modules/cloudfront-oac"
  project         = var.project
  environment     = var.environment
  s3_bucket_arn   = module.s3_frontend.bucket_arn
  s3_bucket_id    = module.s3_frontend.bucket_name
  log_bucket_name = "buckets-pragma-logs"

  acm_certificate_arn = ""
  domain_name         = ""
  tags                = local.tags
}
