# Bastion
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# 最新のAMIを取得
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# SSM Session Manager用IAMロール
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "bastion_ssm" {
  name = "${var.project_name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECRへのdocker loginを許可
resource "aws_iam_role_policy_attachment" "bastion_ecr" {
  role       = aws_iam_role.bastion_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "bastion_ssm" {
  name = "${var.project_name}-bastion-ssm-profile"
  role = aws_iam_role.bastion_ssm.name
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amzn-linux-2023-ami.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.management_a.id
  vpc_security_group_ids = [aws_security_group.management.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_ssm.name

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.project_name}-bastion"
  }
}
