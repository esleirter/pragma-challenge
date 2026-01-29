terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

module "security_group_valkey" {
  #checkov:skip=CKV_TF_1:"Skip has version on the module"
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "SG-elasticache-valkey-${local.name_prefix}"
  description = "Security group for Elasticache Valkey ${local.name_prefix} private subnet"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.port_valkey_writer
      to_port     = var.port_valkey_writer
      protocol    = "tcp"
      description = "Redis Writer ${local.name_prefix}"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
    {
      from_port   = var.port_valkey_reader
      to_port     = var.port_valkey_reader
      protocol    = "tcp"
      description = "Redis Reader ${local.name_prefix}"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    }
  ]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis-access"
  })
}

resource "aws_elasticache_subnet_group" "valkey" {
  name        = "sng-elasticache-valkey-${local.name_prefix}"
  description = "Elasticache subnet group for valkey ${local.name_prefix}"
  subnet_ids  = var.private_subnet_ids
}

resource "aws_elasticache_serverless_cache" "valkey_cache" {
  count = var.instances_count

  daily_snapshot_time      = var.daily_snapshot_time
  engine                   = "valkey"
  major_engine_version     = var.major_engine_version
  snapshot_retention_limit = var.snapshot_retention_limit
  subnet_ids               = var.private_subnet_ids
  security_group_ids       = [module.security_group_valkey.security_group_id]

  name        = "valkey-${local.name_prefix}-serverless${count.index == 0 ? "" : "-${count.index}"}"
  description = "valkey-${local.name_prefix}-serverless${count.index == 0 ? "" : "-${count.index}"}"

  cache_usage_limits {
    data_storage {
      minimum = var.cache_usage_limits.data_storage.minimum
      maximum = var.cache_usage_limits.data_storage.maximum
      unit    = var.cache_usage_limits.data_storage.unit
    }
    ecpu_per_second {
      minimum = var.cache_usage_limits.ecpu_per_second.minimum
      maximum = var.cache_usage_limits.ecpu_per_second.maximum
    }
  }

  tags = merge(
    var.tags,
    {
      Name             = "valkey-${local.name_prefix}-serverless${count.index == 0 ? "" : "-${count.index}"}"
      ApplicationUsage = try(var.application_usages[count.index], "unknown")
    }
  )
}
