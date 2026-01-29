# Terraform AWS CloudFront OAC Module

## 📌 Description

This Terraform module provisions an **Amazon CloudFront distribution using Origin Access Control (OAC)** to securely serve content from private origins such as S3 buckets.

Origin Access Control (OAC) is the **recommended and modern replacement for Origin Access Identity (OAI)** and follows AWS security best practices.

This module is designed for **static frontends**, private S3 origins, and integration with Route53 and ACM, supporting **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

This module creates and configures:

- CloudFront Distribution
- Origin Access Control (OAC)
- Secure integration with private S3 bucket origins
- Default cache behavior and ordered cache behaviors (optional)
- HTTPS-only viewer protocol policy
- Logging configuration (optional)
- Custom error responses (SPA-friendly)
- Support for ACM certificates (custom domains)

---

## 📁 Module Structure

```text
cloudfront-oac/
├── main.tf        # CloudFront distribution and OAC
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Example – CloudFront with private S3 origin (OAC)

```hcl
module "cloudfront" {
  source = "./modules/cloudfront-oac"

  project     = "my-project"
  environment = "prod"

  domain_name = "example.com"
  aliases     = ["www.example.com"]

  acm_certificate_arn = aws_acm_certificate.this.arn

  s3_origin = {
    bucket_domain_name = module.s3_frontend.bucket_domain_name
    bucket_arn         = module.s3_frontend.bucket_arn
  }

  default_root_object = "index.html"

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
| tags | map(string) | Tags applied to CloudFront resources |

---

### Domain & TLS

| Name | Type | Description |
|----|------|-------------|
| domain_name | string | Primary domain name |
| aliases | list(string) | Alternate domain names |
| acm_certificate_arn | string | ACM certificate ARN (must be in us-east-1) |

---

### Origin Configuration

| Name | Type | Description |
|----|------|-------------|
| s3_origin | object | S3 origin configuration |
| s3_origin.bucket_domain_name | string | S3 bucket regional domain |
| s3_origin.bucket_arn | string | S3 bucket ARN |

---

### Cache & Behavior

| Name | Type | Description |
|----|------|-------------|
| default_root_object | string | Default object (e.g. index.html) |
| price_class | string | CloudFront price class |
| enable_ipv6 | bool | Enable IPv6 |
| logging | object | Access logging configuration |

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| distribution_id | CloudFront distribution ID |
| distribution_arn | CloudFront distribution ARN |
| distribution_domain_name | CloudFront domain name |
| hosted_zone_id | CloudFront hosted zone ID |

---

## 🔐 Security & Best Practices

- Uses **Origin Access Control (OAC)** instead of deprecated OAI
- S3 bucket remains private (no public access)
- HTTPS-only viewers enforced
- TLS certificates managed via ACM
- Suitable for SPA deployments with custom error responses

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS CloudFront OAC
