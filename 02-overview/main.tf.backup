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

resource "aws_instance" "example" {
  # ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  # instance_type = "t2.micro"

  # new based on Ubuntu 24.04 in Nov 2025.
  ami           = "ami-0fa3fe0fa7920f68e"
  instance_type ="t3.micro"
}
