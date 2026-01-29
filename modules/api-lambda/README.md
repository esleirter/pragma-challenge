# Terraform AWS API Lambda Module

## 📌 Description

This Terraform module provisions an **AWS Lambda-based API**, following serverless and AWS best practices.

It is designed to deploy Lambda functions exposed via **API Gateway**, supporting modern REST or HTTP APIs.  
The module is suitable for **microservices, backend APIs, and event-driven architectures** in **dev / uat / prod** environments.

---

## 🏗️ What This Module Creates

This module creates and configures:

- AWS Lambda function
- IAM Role and policies with least privilege
- API Gateway (REST or HTTP API, depending on implementation)
- Lambda permissions for API Gateway invocation
- CloudWatch Log Group with configurable retention
- Environment variables for the Lambda function

---

## 📁 Module Structure

```text
api-lambda/
├── main.tf        # Lambda, API Gateway, IAM resources
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── README.md
```

---

## 🚀 Module Usage

### Example – Lambda API

```hcl
module "api_lambda" {
  source = "./modules/api-lambda"

  function_name = "users-api"
  runtime       = "python3.12"
  handler       = "app.handler"

  source_path = "./lambda"

  memory_size = 512
  timeout     = 30

  environment_variables = {
    ENV = "prod"
  }

  tags = {
    Owner     = "backend-team"
    Terraform = "true"
  }
}
```

---

## 📥 Input Variables

### General

| Name | Type | Description |
|----|------|-------------|
| function_name | string | Lambda function name |
| runtime | string | Lambda runtime (e.g. python3.12, nodejs20.x) |
| handler | string | Lambda handler |
| source_path | string | Path to Lambda source code |
| tags | map(string) | Tags applied to resources |

---

### Lambda Configuration

| Name | Type | Description |
|----|------|-------------|
| memory_size | number | Lambda memory size (MB) |
| timeout | number | Lambda timeout (seconds) |
| environment_variables | map(string) | Environment variables |
| log_retention_days | number | CloudWatch log retention |

---

### API Gateway

| Name | Type | Description |
|----|------|-------------|
| api_name | string | API Gateway name |
| stage_name | string | API stage name |
| enable_cors | bool | Enable CORS |
| authorization | string | Authorization type (NONE, IAM, JWT) |

---

## 📤 Outputs

| Name | Description |
|----|-------------|
| lambda_function_name | Lambda function name |
| lambda_function_arn | Lambda function ARN |
| api_endpoint | API Gateway invoke URL |
| api_id | API Gateway ID |

---

## 🔐 Security & Best Practices

- Least-privilege IAM role for Lambda
- CloudWatch Logs enabled with retention control
- Environment variables for configuration (no hardcoding)
- API Gateway permissions scoped to Lambda
- Ready for integration with WAF, custom authorizers, or JWT auth

---

## 🧠 Maintainer

Platform / Cloud Engineering Team  
Terraform Module – AWS API Lambda
