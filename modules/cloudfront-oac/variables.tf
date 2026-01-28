locals {
  name_prefix = "${var.project}-${var.environment}"

  cloudfront_web_acl_id = var.enable_waf ? var.waf_web_acl_id : null

  primary_origin_id   = "primary-s3"
  secondary_origin_id = "backup-origin"
}


variable "project" {
  type        = string
  description = "Nombre del proyecto"
}

variable "environment" {
  type        = string
  description = "Ambiente: dev, uat, prod"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment debe ser dev, uat o prod"
  }
}

variable "s3_bucket_id" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes"
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}


variable "enable_waf" {
  type    = bool
  default = false
}

variable "waf_web_acl_id" {
  type    = string
  default = null

  validation {
    condition     = var.enable_waf == false || (var.enable_waf && var.waf_web_acl_id != null)
    error_message = "Si enable_waf=true debes indicar waf_web_acl_id"
  }
}

variable "enable_logging" {
  type    = bool
  default = false
}

variable "log_bucket_name" {
  type = string
}


variable "enable_failover" {
  type    = bool
  default = false
}

variable "geo_locations" {
  type    = list(string)
  default = ["US"]
}
