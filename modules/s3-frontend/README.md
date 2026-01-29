# Terraform AWS S3 Frontend Module

## 📌 Description

This Terraform module provisions an **AWS S3 bucket configured to host a static frontend application**, following AWS and Terraform best practices.

It is typically used to host:
- Single Page Applications (SPA) such as React, Angular, or Vue
- Static websites (HTML/CSS/JS)
- Frontend assets served behind CloudFront

The module is suitable for **dev / uat / prod** environments and is designed to integrate cleanly with Route53 and CloudFront modules.

---

## 🏗️ What This Module Creates

This module creates and configures:

- S3 bucket for frontend hosting
- Static website hosting configuration (optional)
- Bucket policy for public or CloudFront access
- Block Public Access configuration (recommended)
- Versioning (optional)
- Server-side encryption (SSE-S3 or SSE-KMS)
- Optional access logging

---

## 📁 Module Structure

```text
s3-frontend/
├── main.tf        # S3 bucket and policies
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Basic example – Static frontend bucket

```hcl
module "s3_frontend" {
  source = "./modules/s3-frontend"

  bucket_name = "my-frontend-prod"

  environment = "prod"
  project     = "my-project"

  enable_versioning = true
  force_destroy     = false

  tags = {
    Owner     = "frontend-team"
    Terraform = "true"
  }
}
```

---

### Example – S3 frontend behind CloudFront

```hcl
module "s3_frontend" {
  source = "./modules/s3-frontend"

  bucket_name = "my-frontend-prod"

  block_public_access = true
  cloudfront_origin   = true

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
| bucket_name | string | Name of the S3 bucket |
| project | string | Project name |
| environment | string | Environment (`dev`, `uat`, `prod`) |
| tags | map(string) | Tags applied to the bucket |

---

### Security & Lifecycle

| Name | Type | Description |
|----|------|-------------|
| block_public_access | bool | Enable S3 Block Public Access |
| enable_versioning | bool | Enable object versioning |
| force_destroy | bool | Allow bucket deletion with objects |
| encryption | string | SSE-S3 or SSE-KMS |
| kms_key_id | string | KMS Key ID (if using SSE-KMS) |

---

### Static Website Hosting

| Name | Type | Description |
|----|------|-------------|
| enable_website | bool | Enable static website hosting |
| index_document | string | Index document (default: index.html) |
| error_document | string | Error document (default: index.html) |

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| bucket_id | S3 bucket ID |
| bucket_arn | S3 bucket ARN |
| bucket_domain_name | S3 regional domain name |
| website_endpoint | Website endpoint (if enabled) |

---

## 🔐 Security & Best Practices

- Prefer CloudFront instead of public S3 access
- Enable Block Public Access whenever possible
- Use versioning for rollback safety
- Encrypt buckets using SSE-S3 or SSE-KMS
- Avoid `force_destroy = true` in production

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS S3 Frontend
