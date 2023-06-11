terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

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

