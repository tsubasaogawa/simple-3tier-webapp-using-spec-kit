# Simple 3-Tier Web App on AWS

This project provides a simple 3-tier web application infrastructure on AWS, designed for cost-effectiveness and simplicity. It includes a sample FastAPI application for demonstration purposes.

## Architecture

The infrastructure is defined using Terraform and consists of the following components:

*   **VPC**: A Virtual Private Cloud with a single public subnet to minimize costs associated with NAT Gateways.
*   **Amazon ECS with AWS Fargate**: A serverless compute engine for containers. The application runs as a Fargate task, eliminating the need to manage servers.
*   **Amazon DynamoDB**: A NoSQL database for storing application data (a simple Todo list).
*   **Amazon ECR**: A container registry to store the application's Docker image.
*   **AWS Cloud Map**: For service discovery, allowing API Gateway to find the ECS tasks.
*   **Amazon API Gateway with VPC Link**: Exposes the application's API to the internet. It connects directly to the ECS service via a VPC Link, avoiding the need for a load balancer.

This architecture is optimized for low cost by avoiding managed NAT gateways and load balancers, as detailed in the [research documentation](./specs/001-aws-3tier-webapp/research.md).

## Prerequisites

- An AWS account with administrative privileges.
- AWS CLI configured with your credentials.
- Terraform (v1.0.0 or later).
- Docker.
- Python 3.11 and `uv`.

## Deployment

1.  **Deploy the Infrastructure**

    Use Terraform to create the AWS resources.

    ```bash
    cd terraform
    terraform init
    terraform apply
    ```

2.  **Deploy the Sample Application**

    Build the Docker image for the FastAPI application and push it to ECR.

    ```bash
    # Log in to the ECR repository
    aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)

    # Build and push the Docker image
    cd ../src/app
    docker build -t $(terraform output -raw ecr_repository_url):latest .
    docker push $(terraform output -raw ecr_repository_url):latest
    ```

3.  **Verify the Deployment**

    Retrieve the public IP of the running ECS task and test the API endpoints.

    ```bash
    # Get the public IP of the ECS task
    CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
    TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query 'taskArns[0]' --output text)
    ENI_ID=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
    PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

    echo "Application Public IP: $PUBLIC_IP"

    # Test the API
    curl http://$PUBLIC_IP:8000/todos | jq
    ```

## API Reference

The API is documented using the OpenAPI specification. You can find the specification file here: [openapi.yml](./specs/001-aws-3tier-webapp/contracts/openapi.yml).

## Security

This repository is protected by automated secret scanning using [Gitleaks](https://github.com/gitleaks/gitleaks). The scanning runs:
- On every push to main/develop branches
- On every pull request
- Daily at 2:00 AM UTC
- Can be triggered manually

The repository includes a `.gitleaks.toml` configuration file to customize scanning rules and prevent false positives.

For security best practices and guidelines, please refer to [SECURITY.md](./SECURITY.md).
