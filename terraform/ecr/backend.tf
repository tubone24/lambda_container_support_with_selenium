
terraform {
  backend "s3" {
    key = "terraform/attend_selenium_ecr.tfstate"
    region = "ap-northeast-1"
  }
}