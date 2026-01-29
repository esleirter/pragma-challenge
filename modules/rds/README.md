# Terraform AWS RDS Module

## 📌 Description

This Terraform module provisions an **Amazon RDS database instance** following AWS and Terraform best practices for security, availability, and maintainability.

It is designed to be used by application teams and platform engineers to deploy **managed relational databases** in a consistent and repeatable way across **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

This module creates and configures:

- Amazon RDS DB Instance (single-AZ or multi-AZ)
- DB Subnet Group
- Security Group for database access
- Parameter Group (optional/customizable)
- Option Group (engine-dependent)
- Storage encryption using AWS KMS
- Automated backups and maintenance window configuration
- CloudWatch monitoring and logs export (optional)

---

## 📁 Module Structure

```text
rds/
├── main.tf        # RDS instance and related resources
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Example – PostgreSQL RDS Instance

```hcl
module "rds" {
  source = "./modules/rds"

  identifier = "app-db-prod"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage = 50
  storage_type      = "gp3"

  db_name  = "appdb"
  username = "dbadmin"

  multi_az = true

  subnet_ids         = module.networking.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.app_db.id]

  backup_retention_period = 7
  deletion_protection    = true

  tags = {
    Owner     = "database-team"
    Terraform = "true"
  }
}
```

---

## 📥 Input Variables

### General

| Name | Type | Description |
|----|------|-------------|
| identifier | string | RDS instance identifier |
| engine | string | Database engine (postgres, mysql, mariadb, oracle, sqlserver) |
| engine_version | string | Engine version |
| instance_class | string | RDS instance type |
| tags | map(string) | Tags applied to resources |

---

### Storage & Availability

| Name | Type | Description |
|----|------|-------------|
| allocated_storage | number | Storage size (GB) |
| storage_type | string | Storage type (gp2, gp3, io1) |
| multi_az | bool | Enable Multi-AZ deployment |
| storage_encrypted | bool | Enable storage encryption |
| kms_key_id | string | KMS key for encryption (optional) |

---

### Networking & Security

| Name | Type | Description |
|----|------|-------------|
| subnet_ids | list(string) | Subnets for DB subnet group |
| vpc_security_group_ids | list(string) | Security groups allowed to access DB |
| publicly_accessible | bool | Public accessibility (not recommended) |

---

### Credentials & Database

| Name | Type | Description |
|----|------|-------------|
| db_name | string | Initial database name |
| username | string | Master username |
| password | string | Master password (use secrets manager) |
| port | number | Database port |

---

### Backup & Maintenance

| Name | Type | Description |
|----|------|-------------|
| backup_retention_period | number | Backup retention in days |
| maintenance_window | string | Preferred maintenance window |
| deletion_protection | bool | Prevent accidental deletion |

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| db_instance_id | RDS instance ID |
| db_instance_arn | RDS instance ARN |
| db_endpoint | Database endpoint |
| db_port | Database port |
| db_name | Database name |

---

## 🔐 Security & Best Practices

- Always enable storage encryption
- Use private subnets only
- Avoid `publicly_accessible = true`
- Store credentials in AWS Secrets Manager
- Enable deletion protection in production
- Use Multi-AZ for production workloads

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS RDS
