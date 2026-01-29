terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

data "aws_rds_engine_version" "mysql" {
  engine  = "aurora-mysql"
  version = "8.0.mysql_aurora.3.08.2"
}

data "aws_rds_cluster_parameter_group" "mysql_cluster_pq" {
  name = "default.aurora-mysql8.0"
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "aurora_mysql" {
  depends_on = [aws_rds_cluster_parameter_group.aurora_mysql_cluster]

  cluster_identifier                  = "aurora-serverlessv2-mysql-${local.name_prefix}"
  engine                              = data.aws_rds_engine_version.mysql.engine
  engine_version                      = data.aws_rds_engine_version.mysql.version
  enable_http_endpoint                = false
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.aurora_mysql.name
  vpc_security_group_ids              = [module.security_group_rds.security_group_id]
  master_password                     = random_password.password.result
  deletion_protection                 = true
  master_username                     = "admin"
  port                                = "3307"
  copy_tags_to_snapshot               = true

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 20
  }

  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "iam-db-auth-error",
    "instance",
    "slowquery"
  ]
  performance_insights_enabled = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_mysql_cluster.name

}

resource "aws_rds_cluster_parameter_group" "aurora_mysql_cluster" {
  name        = "aurora-serverlessv2-mysql-${local.name_prefix}-cluster-pg"
  family      = data.aws_rds_cluster_parameter_group.mysql_cluster_pq.family
  description = "RDS cluster parameter group for aurora-serverlessv2-mysql-${local.name_prefix}"

  parameter {
    name         = "binlog_format"
    value        = "ROW"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "binlog_row_image"
    value        = "FULL"
    apply_method = "immediate"
  }

  parameter {
    name         = "binlog_row_metadata"
    value        = "FULL"
    apply_method = "immediate"
  }

}

resource "aws_rds_cluster_instance" "aurora_mysql_instances" {
  depends_on         = [aws_rds_cluster.aurora_mysql]
  count              = 2
  identifier         = "instance-mysql-${local.name_prefix}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_mysql.id
  instance_class     = "db.serverless"
  engine             = "aurora-mysql"
  promotion_tier     = 1

  monitoring_interval        = 5
  auto_minor_version_upgrade = true

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn
}

resource "aws_db_subnet_group" "aurora_mysql" {
  name       = "sng-rds${local.name_prefix}-serverlessv2"
  subnet_ids = var.private_subnet_ids
}


module "security_group_rds" {
  #checkov:skip=CKV_TF_1:"Skip has version on the module"
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "SG-rds-${local.name_prefix}-serverlessv2"
  description = "Security group Mysql ${local.name_prefix} private subnet"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3307
      to_port     = 3307
      protocol    = "tcp"
      description = "For RDS ${local.name_prefix}"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    }
  ]
  tags = var.tags
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for Aurora MySQL encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "rds" {
  name          = "alias/rds-aurora-mysql-${local.name_prefix}"
  target_key_id = aws_kms_key.rds.key_id
}