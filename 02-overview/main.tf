terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "my-learning-directive-tf-state"
  force_destroy = true
  versioning {
    enabled     = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

# Work-in-progress below
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "devops-directive-tf-state"
#   force_destroy = true
#   versioning {
#     enabled = true
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
#   bucket = aws_s3_bucket.devops-directive-tf-state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.mykey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Lockid"

  attribute {
    name = "Lockid"
    type = "S"
  }
}