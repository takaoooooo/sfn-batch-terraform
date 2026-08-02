# VPCエンドポイント用SG
resource "aws_security_group" "egress" {
  name        = "${var.project_name}-egress-sg"
  description = "Security Group for VPC Endpoints"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-egress-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "egress_https" {
  security_group_id = aws_security_group.egress.id
  cidr_ipv4         = data.aws_vpc.main.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.egress.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
