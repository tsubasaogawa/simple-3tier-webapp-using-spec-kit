# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## 技術コンテキスト

この機能は、AWS上に3層Webアプリケーションを構築するためのインフラストラクチャをプロビジョニングします。

- **IaC (Infrastructure as Code)**: Terraformを利用して、すべてのAWSリソースをコードで管理します。
- **フロントエンド層**: AWS API Gatewayを利用して、HTTPリクエストを受け付け、バックエンドにルーティングします。
- **バックエンド層**: AWS ECS Fargateを利用して、コンテナ化されたアプリケーションを実行します。`terraform-aws-modules/ecs` モジュールを使用します。
- **データベース層**: AWS DynamoDBをデータストアとして利用します。
- **アプリケーションロジック**: インフラの動作を検証するため、シンプルなTodoアプリケーション（REST API）をコンテナとしてデプロイします。

### 依存関係と統合

- **外部モジュール**: `terraform-aws-modules/ecs` の利用が必須です。VPC構築のため、`terraform-aws-modules/vpc` の利用も推奨されます。
- **AWSサービス**: API Gateway, ECS (Fargate), DynamoDB, IAM, CloudWatch, VPC などのAWSサービスと連携します。

### 未確定要素とリスク

- **[NEEDS CLARIFICATION]**: Todoアプリケーションの具体的な技術スタック（言語、フレームワーク）が指定されていません。
- **[NEEDS CLARIFICATION]**: VPC、サブネット、セキュリティグループなどの詳細なネットワークアーキテクチャが指定されていません。

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
