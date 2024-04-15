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
  key    = "example-file.txt"

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