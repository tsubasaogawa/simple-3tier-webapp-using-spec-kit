# 実装タスク: AWS 3層Webアプリケーション基盤の構築

**機能ブランチ**: `001-aws-3tier-webapp`
**作成日**: 2025-10-29
**関連計画**: [plan.md](./plan.md)

このドキュメントは、AWS 3層Webアプリケーション基盤の構築に必要な実装タスクを定義します。

## フェーズ0: セットアップ

- [X] **T0.1**: プロジェクトのルートディレクトリに `terraform` ディレクトリを作成し、Terraformのメイン設定ファイル (`main.tf`, `variables.tf`, `outputs.tf`) を作成する。
- [X] **T0.2**: `terraform` ディレクトリ内に `versions.tf` を作成し、AWSプロバイダとTerraformのバージョンを定義する。
- [ ] **T0.3**: `terraform` ディレクトリ内に `vpc.tf` を作成し、単一のパブリックサブネットを持つVPCを定義する。
- [ ] **T0.4**: `terraform` ディレクトリ内に `dynamodb.tf` を作成し、TodoItem用のDynamoDBテーブルを定義する。
- [ ] **T0.5**: `terraform` ディレクトリ内に `ecs.tf` を作成し、ECSクラスタ、タスク定義、サービス、およびCloud Mapサービスディスカバリを定義する。
- [ ] **T0.6**: `terraform` ディレクトリ内に `api_gateway.tf` を作成し、API Gateway、VPCリンク、およびECSサービスへの統合を定義する。
- [ ] **T0.7**: `src/app` ディレクトリを作成し、FastAPIアプリケーションのスケルトンを作成する。
- [ ] **T0.8**: `src/app` ディレクトリ内に `Dockerfile` を作成し、FastAPIアプリケーションをコンテナ化する。
- [ ] **T0.9**: `src/app` ディレクトリ内に `requirements.txt` を作成し、FastAPIとuvicornの依存関係を定義する。

## フェーズ1: テスト

- [ ] **T1.1**: Terraformの単体テスト（`terraform validate`, `terraform fmt --check`）を実行する。
- [ ] **T1.2**: FastAPIアプリケーションの単体テストを作成する。

## フェーズ2: コア実装

- [ ] **T2.1**: FastAPIアプリケーションにTodoItemのCRUDエンドポイントを実装する。
- [ ] **T2.2**: DynamoDBとの連携ロジックを実装する。

## フェーズ3: 統合

- [ ] **T3.1**: Terraformを適用し、AWSインフラをデプロイする。
- [ ] **T3.2**: Dockerイメージをビルドし、ECRにプッシュする。
- [ ] **T3.3**: ECSサービスを更新し、新しいイメージをデプロイする。
- [ ] **T3.4**: API Gateway経由でTodoアプリケーションの動作を確認する。

## フェーズ4: 仕上げ

- [ ] **T4.1**: `quickstart.md` の内容を最終確認し、必要に応じて更新する。
- [ ] **T4.2**: `README.md` を作成し、プロジェクトの概要、セットアップ、デプロイ方法などを記述する。
