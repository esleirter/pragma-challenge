
terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 frontend bucket ${local.bucket_name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3" {
  name          = "alias/s3-${local.bucket_name}"
  target_key_id = aws_kms_key.s3.id
}


resource "aws_s3_bucket" "frontend" {
  bucket = local.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "frontend" {
  bucket        = aws_s3_bucket.frontend.id
  target_bucket = var.log_bucket_name
  target_prefix = "s3-access-logs/${local.bucket_name}"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# resource "aws_s3_bucket_policy" "public_access" {
#   bucket = aws_s3_bucket.frontend.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject",
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = ["s3:GetObject"],
#         Resource  = "${aws_s3_bucket.frontend.arn}/*"
#       }
#     ]
#   })
# }

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
