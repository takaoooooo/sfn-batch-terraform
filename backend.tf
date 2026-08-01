terraform {
  backend "s3" {
    bucket       = "sfn-batch-terraform-state"
    key          = "sfn-batch-terraform/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
  }
}
