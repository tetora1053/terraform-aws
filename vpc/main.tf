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
    key    = "vpc"
    region = "ap-northeast-1"
  }
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

resource "aws_subnet" "tetora_public_1d" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1d"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "tetora_public_1d"
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

resource "aws_subnet" "tetora_private_1d" {
  vpc_id            = aws_vpc.tetora.id
  availability_zone = "ap-northeast-1d"
  cidr_block        = "10.0.13.0/24"
  tags = {
    Name = "tetora_private_1d"
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

resource "aws_route_table" "tetora_private_1d" {
  vpc_id = aws_vpc.tetora.id
  tags = {
    Name = "tetora_private_1d"
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
  nat_gateway_id         = aws_nat_gateway.tetora_nat_1a.id
}

resource "aws_route" "tetora_private_1d" {
  route_table_id         = aws_route_table.tetora_private_1d.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tetora_nat_1a.id
}

resource "aws_route_table_association" "tetora_private_1a" {
  subnet_id      = aws_subnet.tetora_private_1a.id
  route_table_id = aws_route_table.tetora_private_1a.id
}

resource "aws_route_table_association" "tetora_private_1c" {
  subnet_id      = aws_subnet.tetora_private_1c.id
  route_table_id = aws_route_table.tetora_private_1c.id
}

resource "aws_route_table_association" "tetora_private_1d" {
  subnet_id      = aws_subnet.tetora_private_1d.id
  route_table_id = aws_route_table.tetora_private_1d.id
}

output "tetora_private_subnets" {
  value = [
    aws_subnet.tetora_private_1a,
    aws_subnet.tetora_private_1c,
    aws_subnet.tetora_private_1d,
  ]
}
