# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = var.project_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = var.project_name
  }
}

# ------------------------------------------------------------------------------
# ECR Repository
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-app-ecr"
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-app"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-app-log-group"
  }
}

# ------------------------------------------------------------------------------
# IAM Roles for ECS Tasks
# ------------------------------------------------------------------------------

# Execution Role: Allows ECS agent to make AWS API calls on your behalf (e.g., pull ECR images, write logs)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role: Allows the application running in the container to make AWS API calls (e.g., access DynamoDB)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-task-role"
  }
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "${var.project_name}-dynamodb-access-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.todo_items.arn
      },
    ]
  })
}

# ------------------------------------------------------------------------------
# ECS Task Definition
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true
      cpu       = 256
      memory    = 512
      portMappings = [
        {
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-app-task"
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
  name = "app"

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
# ECS Service
# ------------------------------------------------------------------------------

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app.arn
  }

  # Ensure the task definition is updated before the service is created
  depends_on = [aws_ecs_task_definition.app]

  tags = {
    Name = "${var.project_name}-service"
  }
}

# ------------------------------------------------------------------------------
# Security Group for ECS Tasks
# ------------------------------------------------------------------------------

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = var.app_port
    to_port   = var.app_port
    protocol  = "tcp"
    # This should be locked down to the VPC Link's security group in a production setup
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic from API Gateway VPC Link"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}