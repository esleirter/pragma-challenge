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

  backend_services = {
    "api" = {
      path               = "api"
      runtime            = "nodejs18.x"
      handler            = "index.handler"
      zip_key            = "api-lambda.zip"
      authorization_type = "NONE"
    },

    "users" = {
      path               = "users"
      runtime            = "nodejs18.x"
      handler            = "index.handler"
      zip_key            = "users-lambda.zip"
      authorization_type = "JWT"
    }
  }
  tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "Esleirter Vilchez"
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

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}