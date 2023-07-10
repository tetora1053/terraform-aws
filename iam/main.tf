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
    key    = "iam"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# role for ec2 instance profile
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

output "tetora_ec2_role" {
  value = aws_iam_role.tetora_ec2_role
}

# prohibit ec2 stop protection from being enabled
resource "aws_iam_policy" "ec2-dev-policy" {
  name        = "ec2-dev-policy"
  description = "ec2-dev-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "ec2:ModifyInstanceAttribute"
        ]
        Resource = "arn:aws:ec2:ap-northeast-1:${var.account_id}:instance/*"
        "Condition" : {
          "StringEquals" : {
            "ec2:Attribute/DisableApiStop" : "true"
          }
        }
      }
    ]
  })
}
