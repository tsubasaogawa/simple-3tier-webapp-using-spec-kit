# Quickstart: Python 3.13 Upgrade

この機能はアプリケーションのランタイム環境を更新するものであり、開発者が直接利用する新しいエンドポイントや機能はありません。

## 開発環境のセットアップ

1.  **Python 3.13のインストール**:
    ローカル環境にPython 3.13をインストールしてください（pyenvの使用を推奨）。
    ```bash
    pyenv install 3.13.0
    ```

2.  **プロジェクトのPythonバージョン設定**:
    プロジェクトのルートで、使用するPythonバージョンを3.13に設定します。
    ```bash
    pyenv local 3.13.0
    ```

3.  **仮想環境の再構築と依存関係のインストール**:
    既存の仮想環境を削除し、新しいPythonバージョンで再作成します。
    ```bash
    rm -rf src/app/.venv
    python -m venv src/app/.venv
    source src/app/.venv/bin/activate
    pip install -e "src/app[dev]"
    ```

## 動作確認

1.  **テストの実行**:
    すべてのテストが成功することを確認します。
    ```bash
    pytest src/app/tests
    ```

2.  **ローカルサーバーの起動**:
    アプリケーションが正常に起動することを確認します。
    ```bash
    uvicorn src.app.main:app --reload
    ```
