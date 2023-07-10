terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "tetora-poc-terraform-1053"
    key    = "ec2"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "tetora-poc-terraform-1053"
    key    = "vpc"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "tetora-poc-terraform-1053"
    key    = "iam"
    region = "ap-northeast-1"
  }
}

# iam role for ec2 instance profile
resource "aws_iam_instance_profile" "tetora_ec2_profile" {
  name = "tetora_ec2_profile"
  role = data.terraform_remote_state.iam.outputs.tetora_ec2_role.name
}

resource "aws_instance" "app_server" {
  subnet_id            = data.terraform_remote_state.vpc.outputs.tetora_private_subnets.0.id
  ami                  = var.ami_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tetora_ec2_profile.name
  tags = {
    Name = var.instance_name
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}
