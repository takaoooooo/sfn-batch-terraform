# ECSクラスター
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster.html
resource "aws_ecs_cluster" "app" {
  name = "${var.project_name}-app"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
