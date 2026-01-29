# Terraform AWS Networking Module

## 📌 Description

This Terraform module provisions a **complete AWS networking architecture**, following best practices for security, high availability, and observability.

It is designed to be reusable by other infrastructure modules (EC2, EKS, ECS, Lambda, RDS, GitLab Runners, etc.) and to support **dev / uat / prod** environments.

---

## 🏗️ Architecture Overview

This module creates the following resources:

- VPC with configurable CIDR
- 3 Public subnets (one per AZ)
- 3 Private subnets (one per AZ)
- Internet Gateway
- 1 NAT Gateway per AZ (high availability)
- Public and private route tables
- Default Network ACL associated with all subnets
- Default Security Group explicitly neutralized (not usable)
- VPC Flow Logs (REJECT traffic only) sent to CloudWatch
- KMS Key for log encryption
- VPC Endpoints:
  - Interface Endpoints (SSM, EC2, Logs, ECR, etc.)
  - Gateway Endpoint for S3

---

## 📁 Module Structure

```text
networking/
├── main.tf        # Core networking resources
├── variables.tf   # Input variables
├── outputs.tf     # Reusable outputs
└── README.md
```

---

## 🚀 Module Usage

```hcl
module "networking" {
  source = "./modules/networking"

  project     = "my-project"
  environment = "prod"

  vpc_cidr_block = "10.0.0.0/16"

  subnet_public_1a_cidr_block  = "10.0.1.0/24"
  subnet_public_1b_cidr_block  = "10.0.2.0/24"
  subnet_public_1c_cidr_block  = "10.0.3.0/24"

  subnet_private_1a_cidr_block = "10.0.101.0/24"
  subnet_private_1b_cidr_block = "10.0.102.0/24"
  subnet_private_1c_cidr_block = "10.0.103.0/24"

  vpcEndpoints = [
    "ssm",
    "ec2",
    "logs",
    "ecr.api",
    "ecr.dkr"
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
| project | string | Project name |
| environment | string | Environment (`dev`, `uat`, `prod`) |
| tags | map(string) | Common tags applied to all resources |
| vpc_cidr_block | string | VPC CIDR block |

### Subnets

| Name | Description |
|----|-------------|
| subnet_public_1a_cidr_block | Public subnet CIDR (AZ 1a) |
| subnet_public_1b_cidr_block | Public subnet CIDR (AZ 1b) |
| subnet_public_1c_cidr_block | Public subnet CIDR (AZ 1c) |
| subnet_private_1a_cidr_block | Private subnet CIDR (AZ 1a) |
| subnet_private_1b_cidr_block | Private subnet CIDR (AZ 1b) |
| subnet_private_1c_cidr_block | Private subnet CIDR (AZ 1c) |

### Optional Routes

| Name | Type | Description |
|----|------|-------------|
| extra_routes_a | list(map(any)) | Additional routes for AZ 1a |
| extra_routes_b | list(map(any)) | Additional routes for AZ 1b |
| extra_routes_c | list(map(any)) | Additional routes for AZ 1c |

### VPC Endpoints

| Name | Type | Description |
|----|------|-------------|
| vpcEndpoints | list(string) | List of AWS services for Interface Endpoints |

Example:
```hcl
vpcEndpoints = ["ssm", "logs", "ecr.api"]
```

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| vpc_id | VPC ID |
| vpc_cidr_block | VPC CIDR |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| nat_gateway_ids | NAT Gateway IDs |
| nat_eip_addresses | NAT Elastic IP addresses |

---

## 🔐 Security & Best Practices

- Do not commit `.terraform/` or `terraform.tfstate`
- VPC Flow Logs enabled (REJECT traffic only)
- Logs encrypted with KMS
- One NAT Gateway per AZ
- Private connectivity via VPC Endpoints (no internet dependency)

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS Networking
