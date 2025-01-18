variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to integrate with"
  type        = string
}

variable "s3_bucket_path" {
  description = "Path in the S3 bucket to check"
  type        = string
}

resource "aws_api_gateway_rest_api" "main" {
  name = "s3-proxy-${var.environment}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "s3" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  type        = "AWS"
  integration_http_method = "GET"
  uri         = "arn:aws:apigateway:${data.aws_region.current.name}:s3:path/${var.s3_bucket_name}/${var.s3_bucket_path}"
  credentials = aws_iam_role.api_gateway.arn

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Content-Type" = "'application/json'"
  }

  request_templates = {
    "application/json" = <<EOF
#set($s3response = $util.parseJson($input.body))
#if($s3response.status == "healthy")
#set($context.responseOverride.status = 500)
{
  "statusCode": 500,
  "method": "$context.httpMethod",
  "resourcePath": "$context.resourcePath",
  "body": $input.json('$'),
  "status": "healthy",
  "message": "Healthy status triggers failover"
}
#else
#set($context.responseOverride.status = 200)
{
  "statusCode": 200,
  "method": "$context.httpMethod",
  "resourcePath": "$context.resourcePath",
  "body": $input.json('$'),
  "status": "error",
  "message": "Error status maintains primary"
}
#end
EOF
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_integration_response" "s3_success" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
  selection_pattern = ""  # Default response

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $util.parseJson($input.body))
#if($inputRoot.status == "healthy")
#set($context.responseOverride.status = 500)
{
    "status": "healthy",
    "message": "Healthy status triggers failover (500)",
    "code": 500
}
#else
#set($context.responseOverride.status = 200)
{
    "status": "error",
    "message": "Error status maintains primary (200)",
    "code": 200
}
#end
EOF
  }

  depends_on = [aws_api_gateway_integration.s3]
}

resource "aws_api_gateway_integration_response" "s3_error" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "500"
  selection_pattern = ".*error.*"

  response_templates = {
    "application/json" = <<EOF
{
    "status": "error",
    "code": 500
}
EOF
  }

  depends_on = [aws_api_gateway_integration.s3]
}

resource "aws_api_gateway_method_response" "s3_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "s3_500" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "500"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_iam_role" "api_gateway" {
  name = "api-gateway-s3-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3-access-policy"
  role = aws_iam_role.api_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

data "aws_region" "current" {}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  depends_on  = [aws_api_gateway_integration.s3]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id  = aws_api_gateway_rest_api.main.id
  stage_name   = var.environment
}

output "api_gateway_url" {
  value = "${aws_api_gateway_stage.main.invoke_url}/{proxy}"
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.main.id
}
