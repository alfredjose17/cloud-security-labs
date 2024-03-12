output "iam_role_name" {
  value = aws_iam_role.lab_role.name
}

output "iam_role_arn" {
  value = aws_iam_role.lab_role.arn
}

output "policy_name" {
  value = aws_iam_policy.lab_policy.name
}

output "policy_arn" {
  value = aws_iam_policy.lab_policy.arn
}

output "resource_name" {
  value = aws_s3_bucket.lab_bucket.bucket
}

output "resource_arn" {
  value = aws_s3_bucket.lab_bucket.arn
}