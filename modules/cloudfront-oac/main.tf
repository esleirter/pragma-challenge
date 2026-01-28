
terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.name_prefix}-oac-cloudfront-to-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix}-cloudfront-distribution"
  default_root_object = "index.html"

  aliases = var.domain_name != "" ? [var.domain_name] : []

  origin {
    domain_name = "${var.s3_bucket_id}.s3.amazonaws.com"
    origin_id   = local.primary_origin_id

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    s3_origin_config {
      origin_access_identity = null
    }
  }

  dynamic "origin" {
    for_each = var.enable_failover ? [1] : []
    content {
      domain_name = "example.com"
      origin_id   = local.secondary_origin_id

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.enable_failover ? [1] : []
    content {
      origin_id = "origin-group"

      failover_criteria {
        status_codes = [403, 404, 500, 502, 503, 504]
      }

      member { origin_id = local.primary_origin_id }
      member { origin_id = local.secondary_origin_id }
    }
  }

  default_cache_behavior {
    target_origin_id = var.enable_failover ? "origin-group" : local.primary_origin_id

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = "${var.log_bucket_name}.s3.amazonaws.com"
    include_cookies = false
    prefix          = "cloudfront-logs/${local.name_prefix}/"
  }


  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.geo_locations
    }
  }

  web_acl_id = local.cloudfront_web_acl_id

  tags = var.tags
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = var.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFront"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${var.s3_bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.frontend.id}"
        }
      }
    }]
  })
}
