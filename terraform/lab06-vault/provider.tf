provider "vault" {
  address = "http://127.0.0.1:8200"
  skip_child_token = true
 
  auth_login {
    path = "auth/approle/login"
 
    parameters = {
      role_id = "<>"
      secret_id = "<>"
    }
  }
}

data "vault_generic_secret" "aws_creds" {
  path = "secret/aws/credentials"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_creds.data.access_key
  secret_key = data.vault_generic_secret.aws_creds.data.secret_key
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
  required_version = "~> 1.7.2"
}