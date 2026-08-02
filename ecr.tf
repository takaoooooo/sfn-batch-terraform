# ECR
# 予約確定バッチ用リポジトリ
# デフォルトでAES256で暗号化
resource "aws_ecr_repository" "app_reservation" {
  name                 = "${var.project_name}-app-reservation"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 通知登録バッチ用リポジトリ
# デフォルトでAES256で暗号化
resource "aws_ecr_repository" "app_notification" {
  name                 = "${var.project_name}-app-notification"
  # 上書き可能
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
