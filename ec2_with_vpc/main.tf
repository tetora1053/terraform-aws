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

resource "aws_vpc" "tetora" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tetora"
  }
}

resource "aws_subnet" "tetora_public_1a" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "tetora_public_1a"
  }
}

resource "aws_subnet" "tetora_public_1c" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "tetora_public_1c"
  }
}

resource "aws_subnet" "tetora_private_1a" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.11.0/24"
  tags = {
    Name = "tetora_private_1a"
  }
}

resource "aws_subnet" "tetora_private_1c" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.12.0/24"
  tags = {
    Name = "tetora_private_1c"
  }
}

resource "aws_internet_gateway" "tetora" {
  vpc_id = aws_vpc.tetora.id
  tags = {
    Name = "tetora"
  }
}

resource "aws_eip" "tetora_nat_1a" {
  vpc = true
  tags = {
    Name = "tetora_nat_1a"
  }
}

resource "aws_nat_gateway" "tetora_nat_1a" {
  allocation_id = aws_eip.tetora_nat_1a.id
  subnet_id     = aws_subnet.tetora_public_1a.id
  tags = {
    Name = "tetora_nat_1a"
  }
}

resource "aws_eip" "tetora_nat_1c" {
  vpc = true
  tags = {
    Name = "tetora_nat_1c"
  }
}

resource "aws_nat_gateway" "tetora_nat_1c" {
  allocation_id = aws_eip.tetora_nat_1c.id
  subnet_id     = aws_subnet.tetora_public_1c.id
  tags = {
    Name = "tetora_nat_1c"
  }
}

resource "aws_route_table" "tetora_public" {
  vpc_id = aws_vpc.tetora.id
  tags = {
    Name = "tetora_public"
  }
}

resource "aws_route" "tetora_public" {
  route_table_id         = aws_route_table.tetora_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tetora.id
}

resource "aws_route_table_association" "tetora_public_1a" {
  subnet_id      = aws_subnet.tetora_public_1a.id
  route_table_id = aws_route_table.tetora_public.id
}

resource "aws_route_table_association" "tetora_public_1c" {
  subnet_id      = aws_subnet.tetora_public_1c.id
  route_table_id = aws_route_table.tetora_public.id
}

resource "aws_route_table" "tetora_private_1a" {
  vpc_id = aws_vpc.tetora.id
  tags = {
    Name = "tetora_private_1a"
  }
}

resource "aws_route_table" "tetora_private_1c" {
  vpc_id = aws_vpc.tetora.id
  tags = {
    Name = "tetora_private_1c"
  }
}

resource "aws_route" "tetora_private_1a" {
  route_table_id         = aws_route_table.tetora_private_1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tetora_nat_1a.id
}

resource "aws_route" "tetora_private_1c" {
  route_table_id         = aws_route_table.tetora_private_1c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tetora_nat_1c.id
}

resource "aws_route_table_association" "tetora_private_1a" {
  subnet_id      = aws_subnet.tetora_private_1a.id
  route_table_id = aws_route_table.tetora_private_1a.id
}

resource "aws_route_table_association" "tetora_private_1c" {
  subnet_id      = aws_subnet.tetora_private_1c.id
  route_table_id = aws_route_table.tetora_private_1c.id
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
  subnet_id            = aws_subnet.tetora_private_1a.id
  ami                  = var.ami_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.tetora_ec2_profile.name
  tags = {
    Name = var.instance_name
  }
}
