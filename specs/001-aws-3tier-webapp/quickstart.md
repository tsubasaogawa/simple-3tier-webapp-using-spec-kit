# クイックスタートガイド: AWS 3層Webアプリケーション

このガイドは、Terraformを使用してAWSインフラをプロビジョ-ニングし、サンプルTodoアプリケーションをデプロイする手順を説明します。

## 前提条件

- AWSアカウントと、管理者権限を持つIAMユーザーの認証情報が設定済みであること。
- Terraform (v1.0.0以降) がインストール済みであること。
- Dockerがインストール済みであること。
- Python 3.11 と `uv` がインストール済みであること。

## 1. インフラストラクチャのデプロイ

Terraformを使用して、AWS上にVPC, ECS, DynamoDBなどのリソースを構築します。

```bash
# Terraformコードが含まれるディレクトリに移動
cd terraform

# Terraformを初期化
terraform init

# デプロイ計画を確認
terraform plan

# リソースをデプロイ
terraform apply
```

## 2. サンプルアプリケーションのデプロイ

### a. ECRリポジトリへのログイン

Terraformの出力からECRリポジトリのURLを取得し、Dockerをログインさせます。

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)
```

### b. コンテナイメージのビルドとプッシュ

サンプルアプリケーションのコード（`src/`ディレクトリなど）に移動し、コンテナイメージをビルドしてECRにプッシュします。

```bash
# アプリケーションのルートディレクトリに移動
cd ../src/app

# Dockerイメージをビルド
docker build -t $(terraform output -raw ecr_repository_url):latest .

# ECRにイメージをプッシュ
docker push $(terraform output -raw ecr_repository_url):latest
```

## 3. 動作確認

ECSタスクのパブリックIPアドレスを取得し、HTTPクライアント（curlやPostmanなど）を使用してリクエストを送信し、Todo APIが正常に動作することを確認します。

**a. ECSタスクのパブリックIPアドレスを取得**

```bash
# 実行中のタスクARNを取得
TASK_ARN=$(aws ecs list-tasks --cluster $(terraform output -raw ecs_cluster_name) --query 'taskArns[0]' --output text)

# ネットワークインターフェースIDを取得
ENI_ID=$(aws ecs describe-tasks --cluster $(terraform output -raw ecs_cluster_name) --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)

# パブリックIPを取得
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

echo "Application Public IP: $PUBLIC_IP"
```

**b. Todoリストの取得**
```bash
curl http://$PUBLIC_IP:8000/
```
