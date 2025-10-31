# Simple 3-Tier Web App on AWS

[![CI Workflow](https://github.com/tsubasaogawa/simple-3tier-webapp-using-spec-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/tsubasaogawa/simple-3tier-webapp-using-spec-kit/actions/workflows/ci.yml)
[![CD Workflow](https://github.com/tsubasaogawa/simple-3tier-webapp-using-spec-kit/actions/workflows/cd.yml/badge.svg)](https://github.com/tsubasaogawa/simple-3tier-webapp-using-spec-kit/actions/workflows/cd.yml)

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

このプロジェクトはGitHub Actionsを用いたCI/CDパイプラインを構築しており、コードの品質チェック、コンテナイメージのビルドとプッシュ、そしてステージング環境へのデプロイを自動化します。

### CIワークフロー

-   **トリガー**: `main`ブランチ以外のフィーチャーブランチへの`git push`。
-   **内容**: Pythonコードの静的解析（Ruff）と単体テスト（Pytest）を実行し、コード品質を検証します。
-   **結果**: GitHub Actionsの「Actions」タブでワークフローの実行結果を確認できます。

### CDワークフロー

-   **トリガー**: `main`ブランチへのマージ。
-   **内容**: 
    1.  Dockerイメージをビルドし、コミットハッシュでタグ付けしてAmazon ECRにプッシュします。
    2.  Terraformを用いてAWSインフラをプロビジョニングし、ECSサービスを更新して新しいDockerイメージをデプロイします。
-   **認証**: GitHub ActionsはAWS IAM OIDCプロバイダを利用してAWS認証を行います。これにより、AWS認証情報をGitHubリポジトリに直接保存することなく、セキュアにAWSリソースにアクセスできます。
-   **結果**: ステージング環境にアプリケーションの新しいバージョンがデプロイされます。

### デプロイ手順

1.  **フィーチャーブランチの作成と変更**: 新しい機能やバグ修正のためにフィーチャーブランチを作成し、コードを変更します。
    ```bash
    git checkout -b feature/my-new-feature
    # コード変更
    git commit -am "feat: add my new feature"
    ```
2.  **GitHubへのプッシュ**: フィーチャーブランチをGitHubにプッシュすると、CIワークフローが自動的に実行されます。
    ```bash
    git push origin feature/my-new-feature
    ```
3.  **プルリクエストの作成とマージ**: CIワークフローが成功したら、`main`ブランチへのプルリクエストを作成し、レビュー後にマージします。これによりCDワークフローがトリガーされ、ステージング環境へのデプロイが自動的に行われます。

### デプロイの確認

ECSタスクのパブリックIPを取得し、APIエンドポイントをテストすることでデプロイを確認できます。

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
