variable "role_name" {
    default = "lab-role"
}

variable "policy_name" {
    default = "lab-policy"
}

variable "policy_description" {
    default = "Policy for S3 bucket"
}

variable "policy_statement" {
    default =  [
      {
        Action   = "s3:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
}

variable "bucket_name" {
    default = "lab-bucket-2024-03-11"
}