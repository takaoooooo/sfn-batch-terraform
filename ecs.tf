# ECSクラスター
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster.html
resource "aws_ecs_cluster" "app" {
  name = "${var.project_name}-app"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECSクラスターのキャパシティプロバイダー
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers
resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name = aws_ecs_cluster.app.name
  capacity_providers =  ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight =  1
  }
}
