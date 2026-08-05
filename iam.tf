# OIDC認証(CircleCI)
locals {
  circleci_organization_id = "a431a6ad-8b25-476b-a8cf-9b09e27b95de"
}

data "tls_certificate" "cirlceci" {
  url = "https://oidc.circleci.com"
}

resource "aws_iam_openid_connect_provider" "circleci" {
  url             = "https://oidc.circleci.com/org/${local.circleci_organization_id}"
  client_id_list  = [local.circleci_organization_id]
  # サムプリントの計算
  thumbprint_list = data.tls_certificate.cirlceci.certificates.*.sha1_fingerprint
}

# CircleCI用のIAMロール
resource "aws_iam_role" "cirlcleci_role" {
  name = "CircleCIRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.circleci.arn
      }
    }]
  })
}

# CircleCI用のIAMポリシー
# https://zenn.dev/smartround_dev/articles/7e2dbe1e54443c
resource "aws_iam_policy" "circleci" {
  name        = "${var.project_name}-circleci"
  description = "for CircleCI Policy"
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "RegisterTaskDefinition"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "PassRolesInTaskDefinition"
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        # TODO:タスクロールとタスク実行ロールで絞る
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "circleci" {
  name       = "circleci-attachment"
  roles      = [aws_iam_role.cirlcleci_role.name]
  policy_arn = aws_iam_policy.circleci.arn
}
