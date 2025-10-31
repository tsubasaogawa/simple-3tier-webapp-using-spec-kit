variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "simple-3tier-webapp"
}

variable "app_port" {
  description = "Port on which the application runs inside the container"
  type        = number
  default     = 8000
}

variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
  default     = "latest"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
}
