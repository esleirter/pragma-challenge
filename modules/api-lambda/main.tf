terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

############################
# IAM Role + Logs
############################

resource "aws_iam_role" "lambda_exec" {
  for_each = var.services

  name = "${local.name_prefix}-${each.key}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "logs" {
  for_each = var.services

  role       = aws_iam_role.lambda_exec[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

############################
# Security Group
############################

resource "aws_security_group" "lambda" {
  #checkov:skip=CKV_AWS_260:"Public range"
  name        = "${local.name_prefix}-lambda-sg"
  description = "Shared SG for all Lambda functions"
  vpc_id      = var.vpc_id

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]

  tags = var.tags
}

############################
# DLQ (SQS) + Permissions
############################

resource "aws_sqs_queue" "lambda_dlq" {
  name                    = "${local.name_prefix}-lambda-dlq"
  sqs_managed_sse_enabled = true
}

# Permite que CADA lambda role mande mensajes a la DLQ (requisito real para que funcione)
resource "aws_iam_role_policy" "lambda_dlq_send" {
  for_each = var.services

  role = aws_iam_role.lambda_exec[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSendToDLQ"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.lambda_dlq.arn
      }
    ]
  })
}

############################
# Lambda Functions
############################

resource "aws_lambda_function" "this" {
  #checkov:skip=CKV_AWS_272:"Code Signing"
  for_each = var.services

  function_name = "${local.name_prefix}-${each.key}"
  role          = aws_iam_role.lambda_exec[each.key].arn
  handler       = each.value.handler
  runtime       = each.value.runtime

  s3_bucket = var.lambda_bucket
  s3_key    = each.value.zip_key

  # CKV_AWS_115: concurrency limit a nivel función
  reserved_concurrent_executions = var.lambda_reserved_concurrency

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = "Active"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  # CKV_AWS_272: Code Signing
  #ode_signing_config_arn = aws_lambda_code_signing_config.this.arn

  tags = var.tags
}

############################
# API Gateway -> Lambda
############################

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = var.tags
}

resource "aws_lambda_permission" "apigw" {
  for_each = var.services

  statement_id  = "AllowInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.id}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = var.services

  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this[each.key].invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = var.services

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"

  authorization_type = lookup(each.value, "authorization_type", "NONE")

  authorizer_id = (
    each.value.authorization_type == "JWT"
    ? aws_apigatewayv2_authorizer.jwt[0].id
    : null
  )
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  count = local.uses_jwt ? 1 : 0

  api_id          = aws_apigatewayv2_api.http_api.id
  name            = "${local.name_prefix}-jwt-authorizer"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = var.jwt_issuer
    audience = var.jwt_audience
  }
}

