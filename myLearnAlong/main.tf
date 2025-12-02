terraform {

# Assuming initial S3 and DynamoDB is created

  backend "s3" {
    bucket          = "my-learning-directive-tf-state"
    key             = "03-basics/web-app/terraform.tfstate"
    region          = "us-east-1"
    dynamodb_table  = "terraform-state-locking"
    encrypt          = "true"
  }

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

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group" "terraform_instances" {
  name  = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.terraform_instances.id

  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_lb_listener "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"

  # By default, return 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type  = "text/plain"
      message_body  = "Error 404: Page not found"
      status_code   = 404

    }
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name      = "my-example-target-group"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = data.aws_vpc.default_vpc.id

  health_check {
    path      = "/"
    protocol  = "HTTP"
    matcher   = "200"

    interval  = 15
    timeout   = 3
    healthy_threshold = 2
    unhealthly_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "lb_attachement_1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.terraform_instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "lb_attachement_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.terraform_instance_2.id
  port             = 8080
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Lockid"

  attribute {
    name = "Lockid"
    type = "S"
  }
}

resource "aws_instance" "terraform_instance_1" {
  ami             = "ami-0fa3fe0fa7920f68e"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.terraform_instances.name]
  user_data       = <<-EOF
                  #!/bin/bash
                  echo "Hello World from Instance 1" >> index.html
                  python3 -m http.server 8080 &
                  EOF 

}

resource "aws_instance" "terraform_instance_2" {
  ami             = "ami-0fa3fe0fa7920f68e"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.terraform_instances.name]
  user_data       = <<-EOF
                  #!/bin/bash
                  echo "Hello World from Instance 2" >> index.html
                  python3 -m http.server 8080 &
                  EOF 

}
