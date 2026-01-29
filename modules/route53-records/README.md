# Terraform AWS Route53 Records Module

## 📌 Description

This Terraform module manages **Amazon Route 53 DNS records** in a reusable and opinionated way.

It is intended to be used **on top of an existing Route53 Hosted Zone**, separating zone management from record management.  
This pattern is commonly used in platform teams to avoid coupling DNS zones with application records.

The module supports standard DNS records as well as AWS ALIAS records and is suitable for **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

This module creates:

- Route53 DNS records inside an existing hosted zone:
  - A / AAAA
  - CNAME
  - TXT
  - MX
  - SRV
  - ALIAS records (ALB, NLB, CloudFront, API Gateway, etc.)

⚠️ This module **does not create hosted zones**.

---

## 📁 Module Structure

```text
route53-records/
├── main.tf        # Route53 record resources
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Example – Create DNS records in an existing Hosted Zone

```hcl
module "route53_records" {
  source = "./modules/route53-records"

  zone_id = data.aws_route53_zone.this.zone_id

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
      records = ["api.internal.example.com"]
    },
    {
      name = "txt-test"
      type = "TXT"
      ttl  = 60
      records = ["\"terraform-managed\""]
    }
  ]
}
```

---

## 📥 Input Variables

### General

| Name | Type | Description |
|----|------|-------------|
| zone_id | string | Route53 Hosted Zone ID |
| records | list(any) | List of DNS records to create |

---

## 📘 Record Definition

Each record supports the following attributes:

| Field | Required | Description |
|-----|----------|-------------|
| name | yes | Record name (relative to zone) |
| type | yes | DNS record type |
| ttl | no | TTL (required for non-alias records) |
| records | no | Record values (non-alias) |
| alias | no | Alias configuration block |

### Alias block

```hcl
alias = {
  name                   = "<dns_name>"
  zone_id               = "<zone_id>"
  evaluate_target_health = true
}
```

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| record_fqdns | Fully-qualified domain names created |

---

## 🔐 Best Practices & Notes

- Prefer ALIAS records for AWS-managed endpoints
- Do not mix zone creation and record creation in the same module
- Avoid managing the same DNS record in multiple places
- Keep TTLs low for dynamic services

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS Route53 Records
