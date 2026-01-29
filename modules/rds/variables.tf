locals {
  name_prefix = "${var.project}-${var.environment}"
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

variable "tags" {
  type        = map(string)
  description = "Contiene toda la metadata y configuración del proyecto."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the resources will be created"
  nullable    = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnets ID where the resources will be created"
  nullable    = false
}