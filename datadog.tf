# Datadog AWS Integration
# Datadog Marketplace の CloudFormation テンプレートを Terraform に変換したもの
#   SecretsRetrieval         -> Secrets Manager (data.aws_secretsmanager_secret_version)
#   DatadogAPICall           -> datadog_integration_aws_account
#   DatadogIntegrationRole   -> aws_iam_role / aws_iam_policy

terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

variable "datadog_secret_id" {
  description = "Secrets Manager secret name or ARN holding Datadog keys as JSON ({\"api_key\": \"...\", \"app_key\": \"...\"})"
  type        = string
  default     = "datadog/credentials"
}

variable "datadog_site" {
  description = "Datadog Site (datadoghq.com / datadoghq.eu / us3.datadoghq.com など)"
  type        = string
  default     = "ap1.datadoghq.com"
}

variable "datadog_iam_role_name" {
  description = "IAM role name for the Datadog AWS Integration"
  type        = string
  default     = "DatadogIntegrationRole"
}

data "aws_secretsmanager_secret_version" "datadog" {
  secret_id = var.datadog_secret_id
}

locals {
  datadog_credentials = jsondecode(data.aws_secretsmanager_secret_version.datadog.secret_string)
}

provider "datadog" {
  api_key = local.datadog_credentials["api_key"]
  app_key = local.datadog_credentials["app_key"]
  api_url = "https://api.${var.datadog_site}/"
}

data "aws_caller_identity" "current" {}

# Datadog が AssumeRole する際に使う External ID
resource "datadog_integration_aws_external_id" "this" {}

# Datadog が必要とする IAM 権限(Datadog側が管理する最新の一覧)
data "datadog_integration_aws_iam_permissions" "this" {}

resource "aws_iam_policy" "datadog_integration" {
  name = "${var.datadog_iam_role_name}Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = data.datadog_integration_aws_iam_permissions.this.iam_permissions
      Resource = "*"
    }]
  })
}

# DatadogIntegrationRoleStack 相当
resource "aws_iam_role" "datadog_integration" {
  name = var.datadog_iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        # Datadog の AWS アカウント
        AWS = "arn:aws:iam::464622532012:root"
      }
      Condition = {
        StringEquals = {
          "sts:ExternalId" = datadog_integration_aws_external_id.this.id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "datadog_integration" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = aws_iam_policy.datadog_integration.arn
}

# DatadogAPICall 相当(Datadog側にAWSアカウントを登録)
resource "datadog_integration_aws_account" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = "aws"

  aws_regions {
    include_all = true
  }

  auth_config {
    aws_auth_config_role {
      role_name   = aws_iam_role.datadog_integration.name
      external_id = datadog_integration_aws_external_id.this.id
    }
  }

  resources_config {}

  # Forwarderは使用しない
  logs_config {
    lambda_forwarder {}
  }

  metrics_config {
    namespace_filters {
      exclude_only = ["AWS/SQS", "AWS/ElasticMapReduce"]
    }
  }

  traces_config {
    xray_services {}
  }

  depends_on = [aws_iam_role_policy_attachment.datadog_integration]
}

output "datadog_iam_role_name" {
  description = "IAM Role named to be used with the Datadog AWS Integration"
  value       = aws_iam_role.datadog_integration.name
}
