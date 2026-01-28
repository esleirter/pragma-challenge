locals {
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
