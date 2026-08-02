# DBサブネットグループ
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-main"
  description = "DB subnet group for Aurora"
  subnet_ids  = [aws_subnet.db_a.id, aws_subnet.db_c.id]

  tags = {
    Name = "${var.project_name}-main"
  }
}

# Auroraインスタンス
resource "aws_rds_cluster" "main" {
  cluster_identifier   = "${var.project_name}-main"
  engine               = "aurora-postgresql"
  engine_mode          = "provisioned"
  engine_version       = "17.4"
  db_subnet_group_name = aws_db_subnet_group.main.name
  database_name        = "app"
  master_username      = "sfnbatch"
  # Secrets Managerで自動管理
  manage_master_user_password = true
  storage_encrypted           = true
  vpc_security_group_ids      = [aws_security_group.db.id]
  # 最終スナップショットをスキップ有効化
  skip_final_snapshot = true
  # 削除保護を一時的に無効化(1AZ構成での作り直しのため)
  deletion_protection = false
  # RDS Data APIを有効化
  enable_http_endpoint = true

  serverlessv2_scaling_configuration {
    max_capacity             = 4.0
    min_capacity             = 0.0
    seconds_until_auto_pause = 3000
  }
}

resource "aws_rds_cluster_instance" "main" {
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  availability_zone  = "ap-northeast-1a"
}
