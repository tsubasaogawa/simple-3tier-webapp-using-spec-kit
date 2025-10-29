resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  target        = "arn:aws:servicediscovery:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${aws_service_discovery_service.app.id}"

  tags = {
    Name = "${var.project_name}-api"
  }
}

resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.project_name}-vpc-link"
  security_group_ids = [module.ecs.fargate_services["app"].security_group_id]
  subnet_ids         = [aws_subnet.public.id]

  tags = {
    Name = "${var.project_name}-vpc-link"
  }
}

resource "aws_apigatewayv2_integration" "main" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "arn:aws:servicediscovery:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${aws_service_discovery_service.app.id}"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.project_name}-api-stage"
  }
}

data "aws_caller_identity" "current" {}
