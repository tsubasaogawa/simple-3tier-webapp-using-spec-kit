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
