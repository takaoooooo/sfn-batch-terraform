# VPC Endpoint
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint.html

# S3(ゲートウェイ型)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.app.id]

  tags = {
    Name = "${var.project_name}-s3"
  }
}

# ECR API(インターフェース型)
resource "aws_vpc_endpoint" "api" {
  vpc_id              = data.aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.app_a.id, data.aws_subnet.app_c.id]
  security_group_ids  = [aws_security_group.egress.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-api"
  }
}

# Dockerコマンド(インターフェース型)
resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = data.aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.app_a.id, data.aws_subnet.app_c.id]
  security_group_ids  = [aws_security_group.egress.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-dkr"
  }
}

# Secrets Manager(インターフェース型)
resource "aws_vpc_endpoint" "secrets-manager" {
  vpc_id              = data.aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.app_a.id, data.aws_subnet.app_c.id]
  security_group_ids  = [aws_security_group.egress.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-secrets-manager"
  }
}
