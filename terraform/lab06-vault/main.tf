# Create IAM role
resource "aws_iam_role" "lab_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for S3 bucket
resource "aws_iam_policy" "lab_policy" {
  name        = var.policy_name
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = var.policy_statement
  })
}

# Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn = aws_iam_policy.lab_policy.arn
  role       = aws_iam_role.lab_role.name
}

# Use the IAM role to assume for AWS provider
provider "aws" {
  alias = "assume_role"
  assume_role {
    role_arn = aws_iam_role.lab_role.arn
  }
  region = "us-west-2"
}

# Fetch secrets from vault
data "vault_kv_secret_v2" "test-secret" {
  mount = "secret"
  name  = "test-secret"
}

# Use the IAM role to create S3 bucket
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "Vault Secret"
    Secret = data.vault_kv_secret_v2.test-secret.data["username"]
  }
}

# Upload object to S3 bucket
resource "aws_s3_bucket_object" "example_object" {
  bucket = aws_s3_bucket.lab_bucket.id
  key    = "index.html"

  # Specify the path to the file to upload
  source = "/home/alfredjose17/cloud-security/terraform/lab06-vault/example-file.txt"
}

# # Delete IAM policy
# resource "aws_iam_policy" "delete_lab_policy" {
#   name        = var.policy_name
#   description = var.policy_description

#   policy = jsonencode({})
# }

# # Delete IAM role
# resource "aws_iam_role" "delete_lab_role" {
#   name = aws_iam_role.lab_role.name
#   assume_role_policy = jsonencode({})
# }

# Define the AWS Lambda function
resource "aws_lambda_function" "example_lambda" {
  filename      = "lambda_function.py"
  function_name = "example_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"

  # environment {
  #   variables = {
  #     ENV_VAR_KEY = "value"
  #   }
  # }
}

# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })

  # Attach a basic policy granting Lambda execution permissions
  // Modify this policy based on your specific requirements
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# Define the API Gateway and its resources
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "Example API Gateway"
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

# Define the API Gateway method and integration with Lambda
resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [aws_api_gateway_integration.example_integration]
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "dev"  # Specify your desired stage name
}