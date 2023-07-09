terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "tetora-poc-terraform-1053"
    key    = "path/to/my/ec2"
    region = "ap-northeast-1"
  }
  required_version = ">= 1.2.0"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "tetora-poc-terraform-1053"
    key    = "path/to/my/key"
    region = "ap-northeast-1"
  }
}

# iam role for ec2 instance profile
resource "aws_iam_role" "tetora_ec2_role" {
  name               = "tetora_ec2_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tetora_ec2_role_policy_attachment" {
  role       = aws_iam_role.tetora_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tetora_ec2_profile" {
  name = "tetora_ec2_profile"
  role = aws_iam_role.tetora_ec2_role.name
}



resource "aws_instance" "app_server" {
  subnet_id            = data.terraform_remote_state.vpc.outputs.tetora_private_1a_id
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
