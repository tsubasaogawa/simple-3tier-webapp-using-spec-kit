# Simple 3-Tier Web App on AWS

This project provides a simple 3-tier web application infrastructure on AWS, designed for cost-effectiveness and simplicity. It includes a sample FastAPI application for demonstration purposes.

## Architecture

The infrastructure is defined using Terraform and consists of the following components:

*   **VPC**: A Virtual Private Cloud with a single public subnet.
*   **Amazon ECS with AWS Fargate**: A serverless compute engine for containers. The application runs as a Fargate task with a public IP, eliminating the need to manage servers or load balancers.
*   **Amazon DynamoDB**: A NoSQL database for storing application data.
*   **Amazon ECR**: A container registry to store the application's Docker image.

This architecture is optimized for low cost by avoiding managed NAT gateways, load balancers, API Gateway, and other managed services.

## Active Technologies
- Python 3.13.0
- FastAPI
- Uvicorn
- Boto3
- Terraform
- Docker
- AWS (ECS, Fargate, DynamoDB, ECR, VPC)

## Project Structure
```
.
├── GEMINI.md
├── README.md
├── specs
│   ├── 001-aws-3tier-webapp
│   └── 002-upgrade-python-version
├── src
│   └── app
│       ├── Dockerfile
│       ├── main.py
│       ├── pyproject.toml
│       └── tests
└── terraform
    ├── main.tf
    ├── variables.tf
    └── versions.tf
```

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

## Recent Changes
- **002-upgrade-python-version**: Upgraded Python version to 3.13 and updated dependencies.
- **001-aws-3tier-webapp**: Initial setup of the 3-tier web application on AWS.

## Security

This repository is protected by automated secret scanning using [Gitleaks](https://github.com/gitleaks/gitleaks). The scanning runs:
- On every push to main/develop branches
- On every pull request
- Daily at 2:00 AM UTC
- Can be triggered manually

The repository includes a `.gitleaks.toml` configuration file to customize scanning rules and prevent false positives.

For security best practices and guidelines, please refer to [SECURITY.md](./SECURITY.md).
