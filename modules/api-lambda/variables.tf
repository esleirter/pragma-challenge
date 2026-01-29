locals {
  name_prefix = "${var.project}-${var.environment}"
  uses_jwt = anytrue([
    for s in var.services :
    s.authorization_type == "JWT"
  ])
}


variable "project" {
  description = "Nombre del proyecto (ej: ecommerce)"
  type        = string
}

variable "environment" {
  description = "Entorno: dev, uat, prod"
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Ambiente inválido. Usa: dev, uat o prod"
  }
}

variable "services" {
  description = "Map of Lambda services"
  type = map(object({
    path               = string
    runtime            = string
    handler            = string
    zip_key            = string
    authorization_type = string
    authorizer_id      = optional(string)
  }))
}

variable "lambda_bucket" {
  description = "S3 bucket where Lambda ZIPs are stored"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Lambdas will run"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the Lambda functions"
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency per Lambda function (function-level concurrency limit)"
  type        = number
  default     = 10
}

variable "jwt_issuer" {
  type        = string
  description = "JWT issuer"
  default     = null
}

variable "jwt_audience" {
  type        = list(string)
  description = "JWT audience"
  default     = []
}



variable "tags" {
  type = map(string)
}