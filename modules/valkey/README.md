# Terraform AWS Valkey Module

## 📌 Description

This Terraform module provisions an **AWS-managed Valkey cluster** (Redis-compatible, open-source fork) using Amazon ElastiCache–style resources and best practices.

Valkey is commonly used for:
- Caching layers
- Session storage
- Real-time data access
- Pub/Sub workloads

This module is designed for **high availability, security, and performance**, and is suitable for **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

This module creates and configures:

- Valkey (Redis-compatible) replication group
- Primary and replica nodes
- Subnet group using private subnets
- Security group with controlled ingress
- Parameter group (optional/custom)
- Automatic failover (Multi-AZ)
- Encryption at rest and in transit
- CloudWatch monitoring and metrics

---

## 📁 Module Structure

```text
valkey/
├── main.tf        # Valkey / ElastiCache resources
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Example – Valkey cluster (Multi-AZ)

```hcl
module "valkey" {
  source = "./modules/valkey"

  name = "cache-prod"

  engine_version = "7.x"
  node_type      = "cache.t4g.medium"

  num_cache_clusters = 2
  multi_az_enabled   = true
  automatic_failover = true

  subnet_ids = module.networking.private_subnet_ids

  allowed_security_group_ids = [
    aws_security_group.app.id
  ]

  tags = {
    Owner     = "platform-team"
    Terraform = "true"
  }
}
```

---

## 📥 Input Variables

### General

| Name | Type | Description |
|----|------|-------------|
| name | string | Valkey replication group name |
| tags | map(string) | Tags applied to resources |

---

### Cluster Configuration

| Name | Type | Description |
|----|------|-------------|
| engine_version | string | Valkey / Redis engine version |
| node_type | string | Cache node instance type |
| num_cache_clusters | number | Number of cache nodes |
| port | number | Cache port (default: 6379) |

---

### Availability & Resilience

| Name | Type | Description |
|----|------|-------------|
| multi_az_enabled | bool | Enable Multi-AZ |
| automatic_failover | bool | Enable automatic failover |
| maintenance_window | string | Maintenance window |
| snapshot_retention_limit | number | Snapshot retention (days) |

---

### Networking & Security

| Name | Type | Description |
|----|------|-------------|
| subnet_ids | list(string) | Private subnet IDs |
| allowed_security_group_ids | list(string) | Security groups allowed to connect |
| transit_encryption_enabled | bool | Enable encryption in transit |
| at_rest_encryption_enabled | bool | Enable encryption at rest |

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| replication_group_id | Valkey replication group ID |
| primary_endpoint | Primary endpoint |
| reader_endpoint | Reader endpoint |
| port | Cache port |

---

## 🔐 Security & Best Practices

- Deploy Valkey only in private subnets
- Enable encryption at rest and in transit
- Restrict access via security groups
- Enable Multi-AZ and automatic failover for production
- Use snapshots for backup and recovery

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS Valkey
