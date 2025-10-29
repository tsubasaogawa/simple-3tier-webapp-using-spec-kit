# クイックスタートガイド: AWS 3層Webアプリケーション

このガイドは、Terraformを使用してAWSインフラをプロビジョニングし、サンプルTodoアプリケーションをデプロイする手順を説明します。

## 前提条件

- AWSアカウントと、管理者権限を持つIAMユーザーの認証情報が設定済みであること。
- Terraform (v1.0.0以降) がインストール済みであること。
- Dockerがインストール済みであること。
- Python 3.11 と `uv` がインストール済みであること。

## 1. インフラストラクチャのデプロイ

Terraformを使用して、AWS上にVPC, API Gateway, ECS, DynamoDBなどのリソースを構築します。

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

`apply`が完了すると、API GatewayのエンドポイントURLなど、重要な出力が表示されます。

## 2. サンプルアプリケーションのデプロイ

### a. ECRリポジトリへのログイン

Terraformの出力からECRリポジトリのURLを取得し、Dockerをログインさせます。

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin [ECRリポジトリのURL]
```

### b. コンテナイメージのビルドとプッシュ

サンプルアプリケーションのコード（`src/`ディレクトリなど）に移動し、コンテナイメージをビルドしてECRにプッシュします。

```bash
# アプリケーションのルートディレクトリに移動
cd ../src/app

# Dockerイメージをビルド
docker build -t [ECRリポジトリのURL]:latest .

# ECRにイメージをプッシュ
docker push [ECRリポジトリのURL]:latest
```

## 3. 動作確認

Terraformの出力にあるAPI GatewayのエンドポイントURLに対して、HTTPクライアント（curlやPostmanなど）を使用してリクエストを送信し、Todo APIが正常に動作することを確認します。

**例: Todoリストの取得**
```bash
curl https://[API GatewayのエンドポイントURL]/todos
```
