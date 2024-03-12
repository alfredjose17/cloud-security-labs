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

# Use the IAM role to create S3 bucket
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.bucket_name
}