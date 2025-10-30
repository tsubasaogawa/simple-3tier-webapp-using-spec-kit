# Tasks: Pythonバージョンアップグレード

**Input**: Design documents from `/specs/002-upgrade-python-version/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: この機能は既存のテストがすべてパスすることが要件のため、テストの記述タスクは含みません。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 開発環境のPythonバージョンを設定します。

- [X] T001 [P] プロジェクトルートの `.python-version` ファイルを `3.13.0` に更新します。
- [X] T002 [P] `src/app/.python-version` ファイルを `3.13.0` に更新します。

---

## Phase 2: User Story 1 - 開発者がPython 3.13でアプリケーションを実行できる (Priority: P1) 🎯 MVP

**Goal**: アプリケーションのランタイムと依存関係をPython 3.13に更新し、正常に動作することを確認します。

**Independent Test**: `pytest src/app/tests` を実行し、すべてのテストが成功することを確認します。ローカルサーバーを起動し、アプリケーションがエラーなく起動することも確認します。

### Implementation for User Story 1

- [X] T003 [US1] `src/app/Dockerfile` のベースイメージを `python:3.13-slim` に更新します。
- [ ] T004 [US1] `src/app/pyproject.toml` の `requires-python` を `>=3.13` に更新します。
- [ ] T005 [US1] 仮想環境を再構築し、`pip install -e "src/app[dev]"` を実行して依存関係をインストールします。
- [ ] T006 [US1] `pytest src/app/tests` を実行し、すべてのテストが成功することを確認します。
- [ ] T007 [US1] `uvicorn src.app.main:app --reload` を実行し、ローカルサーバーが正常に起動することを確認します。

---

## Phase 3: Polish & Cross-Cutting Concerns

**Purpose**: デプロイメント設定を更新します。

- [ ] T008 [P] `terraform/ecs.tf` および関連するTerraformファイルで、ECSタスク定義がPython 3.13を使用するDockerイメージを参照するように更新します。
- [ ] T009 Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **User Story 1 (Phase 2)**: Depends on Setup completion.
- **Polish (Phase 3)**: Depends on User Story 1 completion.

### Parallel Opportunities

- T001とT002は並行して実行可能です。

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: User Story 1
3. **STOP and VALIDATE**: Test User Story 1 independently
4. Deploy/demo if ready

### Incremental Delivery

1.  Setup (Phase 1) を完了します。
2.  User Story 1 (Phase 2) を完了し、ローカルでの動作を確認します。
3.  Polish (Phase 3) を完了し、デプロイ可能な状態にします。
