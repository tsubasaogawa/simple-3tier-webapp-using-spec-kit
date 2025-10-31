terraform {
  backend "s3" {
    key            = "simple-3tier-webapp/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "simple-3tier-webapp-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# 他のTerraformファイルで定義されるリソースがここに統合されます
