output "bucket_name" {
  value = local.bucket_name
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "bucket_arn" {
  value = aws_s3_bucket.frontend.arn
}
