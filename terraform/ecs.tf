# ------------------------------------------------------------------------------
# ECS (using terraform-aws-modules/ecs)
# ------------------------------------------------------------------------------

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = var.project_name

  # Fargate configuration
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  # ECR Repository
  ecr_repository_name = var.project_name
  ecr_repository_image_tag_mutability = "MUTABLE"
  ecr_repository_scan_on_push         = true

  # Task Definition
  task_definition_cpu                      = 256
  task_definition_memory                   = 512
  task_definition_requires_compatibilities = ["FARGATE"]
  task_definition_network_mode             = "awsvpc"
  task_definition_family                   = "${var.project_name}-app"

  task_definition_container_definitions = {
    app = {
      name      = "${var.project_name}-app"
      image     = "PLACEHOLDER_IMAGE_URL" # This will be updated with the ECR repo URL later
      essential = true
      cpu       = 256
      memory    = 512
      port_mappings = [
        {
          name          = "${var.project_name}-app-port"
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DYNAMODB_TABLE_NAME"
          value = aws_dynamodb_table.todo_items.name
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  }

  # Task Role with DynamoDB access
  task_iam_role_name = "${var.project_name}-task-role"
  task_iam_policies = {
    DynamoDBAccess = {
      statement = [
        {
          actions = [
            "dynamodb:BatchGetItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan",
          ]
          resources = [aws_dynamodb_table.todo_items.arn]
        }
      ]
    }
  }

  # Fargate Service
  fargate_services = {
    app = {
      name                              = "${var.project_name}-service"
      desired_count                     = 1
      cpu                               = 256
      memory                            = 512
      assign_public_ip                  = true
      subnets                           = [aws_subnet.public.id]
      security_group_rules = {
        ingress_vpc_app_port = {
          type        = "ingress"
          from_port   = var.app_port
          to_port     = var.app_port
          protocol    = "tcp"
          cidr_blocks = [aws_vpc.main.cidr_block]
          description = "Allow traffic from within the VPC on the app port"
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      # Service Discovery
      service_registries = {
        arn = aws_service_discovery_service.app.arn
      }
    }
  }

  tags = {
    Project = var.project_name
  }
}

# ------------------------------------------------------------------------------
# Service Discovery (Cloud Map)
# ------------------------------------------------------------------------------

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  description = "Private DNS Namespace for ${var.project_name}"
  vpc         = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sd-namespace"
  }
}

resource "aws_service_discovery_service" "app" {
  name        = "app"
  description = "Service Discovery for ${var.project_name} app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "${var.project_name}-sd-service"
  }
}

# ------------------------------------------------------------------------------
# Workaround for dynamic ECR image URL in task definition
# ------------------------------------------------------------------------------

# The ECS module does not directly support using the ECR repository it creates
# within the container definition of the task definition it also creates.
# We use a local to merge the dynamic URL into the definition.

locals {
  # The module creates an ECR repository and its URL is available in module.ecs.ecr_repository_url
  # We need to inject this URL into the container definition.
  container_definitions_with_image = {
    app = {
      name      = "${var.project_name}-app"
      image     = module.ecs.ecr_repository_url # Using the dynamic URL from the module's output
      essential = true
      cpu       = 256
      memory    = 512
      port_mappings = [
        {
          name          = "${var.project_name}-app-port"
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DYNAMODB_TABLE_NAME"
          value = aws_dynamodb_table.todo_items.name
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  }
}

# We need to override the task definition created by the module with one that has the correct image URL.
# Since the module doesn't allow direct overriding, we create a separate task definition
# and will update the service to use it in a later step or manually.
# For now, the module creates a placeholder. A more advanced setup might use a null_resource to run a local-exec provisioner.
# For simplicity, we will create the resources and note that the image needs to be specified when running the task.
# The quickstart guide will reflect this.
