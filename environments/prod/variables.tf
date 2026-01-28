locals {

  records = {
    "www" = {
      type            = "A"
      alias           = true
      target          = module.cloudfront_frontend.cloudfront_domain
      zone_id         = "Z2FDTNDATAQYW2"
      evaluate_health = false
    }

    "api" = {
      type   = "CNAME"
      alias  = false
      target = "api.example.com"
    }

    "backoffice" = {
      type   = "CNAME"
      alias  = false
      target = "backoffice.provider.com"
    }
  }
  tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "cloudops"
    CostCenter  = "12345"
    Terraform   = "true"
  }
}


variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, uat, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Ambiente debe ser dev, uat o prod"
  }
}
