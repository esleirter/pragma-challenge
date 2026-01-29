# Terraform AWS Route53 Module

## 📌 Description

This Terraform module manages **Amazon Route 53 DNS resources** in a clean, reusable, and production-ready way.

It is designed to be consumed by application and infrastructure modules that require:
- Public or private DNS zones
- DNS records (A, AAAA, CNAME, ALIAS, TXT, etc.)
- Integration with AWS services such as ALB, NLB, CloudFront, and API Gateway

The module follows Terraform and AWS best practices and is suitable for **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

Depending on the configuration, this module can create:

- Route 53 Hosted Zones (public and/or private)
- Association of private hosted zones with VPCs
- DNS records:
  - A / AAAA
  - CNAME
  - TXT
  - MX
  - ALIAS records (ALB, NLB, CloudFront, etc.)

---

## 📁 Module Structure

```text
route53/
├── main.tf        # Route53 resources
├── variables.tf   # Input variables
├── outputs.tf     # Module outputs
└── README.md
```

---

## 🚀 Module Usage

### Basic example – Public Hosted Zone with records

```hcl
module "route53" {
  source = "./modules/route53"

  domain_name = "example.com"

  records = [
    {
      name = "www"
      type = "A"
      alias = {
        name                   = aws_lb.alb.dns_name
        zone_id               = aws_lb.alb.zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "api"
      type = "CNAME"
      ttl  = 300
      records = ["api.example.com"]
    }
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
| domain_name | string | Domain name for the hosted zone |
| tags | map(string) | Tags applied to Route53 resources |

---

### Hosted Zone Configuration

| Name | Type | Description |
|----|------|-------------|
| private_zone | bool | Whether the hosted zone is private |
| vpc_id | string | VPC ID for private hosted zones |
| vpc_region | string | AWS region of the VPC (private zones) |

---

### DNS Records

| Name | Type | Description |
|----|------|-------------|
| records | list(any) | List of DNS records to create |

Each record supports:
- `name`
- `type`
- `ttl` (optional for non-alias)
- `records` (for standard records)
- `alias` (for ALIAS records)

Example:
```hcl
records = [
  {
    name = "app"
    type = "A"
    ttl  = 300
    records = ["1.2.3.4"]
  }
]
```

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| hosted_zone_id | Route53 Hosted Zone ID |
| hosted_zone_name | Hosted Zone domain name |
| name_servers | Name servers (public zones) |

---

## 🔐 Best Practices & Notes

- Use ALIAS records instead of CNAME for AWS load balancers
- Keep TTLs low for frequently changing endpoints
- Avoid managing the same record in multiple modules
- For private zones, ensure correct VPC association

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS Route53
