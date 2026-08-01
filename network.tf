# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-main"
  }
}


# Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# アプリケーション用
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_name}-private-app-a"
  }
}

resource "aws_subnet" "app_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.9.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_name}-private-app-c"
  }
}

# DB用
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_name}-private-db-a"
  }
}

resource "aws_subnet" "db_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.17.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_name}-private-db-c"
  }
}

# 管理用
resource "aws_subnet" "management_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.240.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_name}-public-management-a"
  }
}

# 管理用（予備）
resource "aws_subnet" "management_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.241.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_name}-public-management-c"
  }
}

# Egress用
resource "aws_subnet" "egress_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.248.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.project_name}-private-egress-a"
  }
}

resource "aws_subnet" "egress_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.249.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.project_name}-private-egress-c"
  }
}
