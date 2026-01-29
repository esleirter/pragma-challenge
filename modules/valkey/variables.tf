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

variable "instances_count" {
  type        = number
  description = "Number of Valkey clusters to be created."
  default     = 1
}

variable "port_valkey_writer" {
  type        = number
  description = "Port number for Valkey writer instance."
  default     = 6379
}

variable "port_valkey_reader" {
  type        = number
  description = "Port number for Valkey reader instance."
  default     = 6380
}

variable "snapshot_retention_limit" {
  type    = number
  default = 10
}

variable "major_engine_version" {
  description = "Versión mayor del motor Valkey"
  type        = string
  default     = "7"
}

variable "daily_snapshot_time" {
  description = "Hora diaria para tomar snapshots"
  type        = string
  default     = "06:30"
}


variable "application_usages" {
  type        = list(string)
  description = "Application usage tag for each instance"
  default     = []
  validation {
    condition     = length(var.application_usages) == var.instances_count
    error_message = "Length of application_usages must match instances_count"
  }
}

variable "cache_usage_limits" {
  description = "Configuración global de cache usage limits"
  type = object({
    data_storage = object({
      minimum = number
      maximum = number
      unit    = string
    })
    ecpu_per_second = object({
      minimum = number
      maximum = number
    })
  })

  default = {
    data_storage = {
      minimum = 1
      maximum = 200
      unit    = "GB"
    }
    ecpu_per_second = {
      minimum = 1000
      maximum = 15000000
    }
  }
}
