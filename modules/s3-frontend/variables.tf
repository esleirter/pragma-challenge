locals {
  bucket_name = "${var.project}-${var.environment}-frontend"
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

variable "index_document" {
  default     = "index.html"
  description = "Documento raíz del sitio"
  type        = string
}

variable "error_document" {
  default     = "error.html"
  description = "Documento de error del sitio"
  type        = string
}

variable "log_bucket_name" {
  description = "Existing S3 bucket name used for access logs"
  type        = string
}

variable "tags" {
  description = "Mapa de tags para aplicar a los recursos"
  type        = map(string)
}