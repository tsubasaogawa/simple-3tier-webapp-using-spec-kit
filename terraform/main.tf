provider "aws" {
  region = var.aws_region
}

# 他のTerraformファイルで定義されるリソースがここに統合されます
