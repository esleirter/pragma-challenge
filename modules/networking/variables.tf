
locals {
  name_prefix = "${var.project}-${var.environment}"
  region      = var.region
  tags        = var.tags
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

variable "region" {
  type        = string
  description = "AWS Region"
  nullable    = false
  default     = "us-east-1"
}


### VPC Variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "rt_public_route1_cidr_block" {
  description = "CIDR block for the public route table route 1"
  type        = string
  default     = "0.0.0.0/0"
}

variable "extra_routes_a" {
  type = list(object({
    cidr_block                 = optional(string)
    ipv6_cidr_block            = optional(string)
    gateway_id                 = optional(string)
    nat_gateway_id             = optional(string)
    transit_gateway_id         = optional(string)
    vpc_endpoint_id            = optional(string)
    vpc_peering_connection_id  = optional(string)
    network_interface_id       = optional(string)
    egress_only_gateway_id     = optional(string)
    local_gateway_id           = optional(string)
    carrier_gateway_id         = optional(string)
    core_network_arn           = optional(string)
    destination_prefix_list_id = optional(string)
    instance_id                = optional(string)
  }))
  default = []
}
variable "extra_routes_b" {
  type = list(object({
    cidr_block                 = optional(string)
    ipv6_cidr_block            = optional(string)
    gateway_id                 = optional(string)
    nat_gateway_id             = optional(string)
    transit_gateway_id         = optional(string)
    vpc_endpoint_id            = optional(string)
    vpc_peering_connection_id  = optional(string)
    network_interface_id       = optional(string)
    egress_only_gateway_id     = optional(string)
    local_gateway_id           = optional(string)
    carrier_gateway_id         = optional(string)
    core_network_arn           = optional(string)
    destination_prefix_list_id = optional(string)
    instance_id                = optional(string)
  }))
  default = []
}

variable "extra_routes_c" {
  type = list(object({
    cidr_block                 = optional(string)
    ipv6_cidr_block            = optional(string)
    gateway_id                 = optional(string)
    nat_gateway_id             = optional(string)
    transit_gateway_id         = optional(string)
    vpc_endpoint_id            = optional(string)
    vpc_peering_connection_id  = optional(string)
    network_interface_id       = optional(string)
    egress_only_gateway_id     = optional(string)
    local_gateway_id           = optional(string)
    carrier_gateway_id         = optional(string)
    core_network_arn           = optional(string)
    destination_prefix_list_id = optional(string)
    instance_id                = optional(string)
  }))
  default = []
}

variable "subnet_private_1a_cidr_block" {
  description = "CIDR block for private subnet 1a"
  type        = string
  default     = ""
}

variable "subnet_private_1b_cidr_block" {
  description = "CIDR block for private subnet 1b"
  type        = string
  default     = ""
}

variable "subnet_private_1c_cidr_block" {
  description = "CIDR block for private subnet 1c"
  type        = string
  default     = ""
}

variable "subnet_public_1a_cidr_block" {
  description = "CIDR block for public subnet 1a"
  type        = string
  default     = ""
}

variable "subnet_public_1b_cidr_block" {
  description = "CIDR block for public subnet 1b"
  type        = string
  default     = ""
}

variable "subnet_public_1c_cidr_block" {
  description = "CIDR block for public subnet 1c"
  type        = string
  default     = ""
}

variable "vpcEndpoints" {
  type        = list(string)
  description = "List of VPC endpoints to create"
  default = [
    "ssm",
    "ec2messages",
    "ec2",
    "ssmmessages",
    "kms",
    "logs",
    "ecr.api",
    "ecr.dkr",
    "ssm-incidents",
  ]
}
