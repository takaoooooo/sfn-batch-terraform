data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-main"]
  }
}

data "aws_subnet" "app_a" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-app-a"]
  }
}

data "aws_subnet" "app_c" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-app-c"]
  }
}

data "aws_route_table" "app" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-app"]
  }
}
