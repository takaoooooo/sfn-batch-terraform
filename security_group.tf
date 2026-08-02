# Security Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# Management
resource "aws_security_group" "management" {
  name        = "${var.project_name}-management-sg"
  description = "Security Group for Management"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-management-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
resource "aws_vpc_security_group_egress_rule" "management" {
  security_group_id = aws_security_group.management.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# DB
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security Group for DB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "db" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
