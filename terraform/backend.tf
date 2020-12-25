
terraform {
  backend "s3" {
    key = "terraform/attend_selenium.tfstate"
    region = "ap-northeast-1"
  }
}