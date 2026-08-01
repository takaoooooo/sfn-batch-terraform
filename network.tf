# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-main"
  }
}

# Internet Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

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
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.240.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-management-a"
  }
}

# 管理用（予備）
resource "aws_subnet" "management_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.241.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

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

# Route Table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# アプリケーション用（app_a/app_cで共有）
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app"
  }
}

# 管理用（management_a/management_cで共有）
resource "aws_route_table" "management" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-management"
  }
}

# DB用・Egress用は専用ルートテーブルを作らず、VPCのデフォルトルートテーブルに任せる

# Route Table Association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "app_c" {
  subnet_id      = aws_subnet.app_c.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "management_a" {
  subnet_id      = aws_subnet.management_a.id
  route_table_id = aws_route_table.management.id
}

resource "aws_route_table_association" "management_c" {
  subnet_id      = aws_subnet.management_c.id
  route_table_id = aws_route_table.management.id
}
