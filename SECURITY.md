# セキュリティガイドライン / Security Guidelines

このドキュメントは、リポジトリのセキュリティを維持するためのベストプラクティスをまとめています。

This document outlines best practices for maintaining repository security.

## 機密情報の管理 / Managing Sensitive Information

### ❌ コミットしてはいけないもの / DO NOT Commit

以下の情報は**絶対に**リポジトリにコミットしないでください：

The following information should **NEVER** be committed to the repository:

- AWSアクセスキー・シークレットキー / AWS Access Keys & Secret Keys
- APIキー・トークン / API Keys & Tokens
- パスワード / Passwords
- プライベートキー(.pem, .key, id_rsa等) / Private Keys (.pem, .key, id_rsa, etc.)
- データベース接続文字列 / Database Connection Strings
- その他の認証情報 / Other Credentials

### ✅ 推奨される方法 / Recommended Practices

1. **環境変数を使用する / Use Environment Variables**
   ```python
   # Good
   db_password = os.environ.get("DB_PASSWORD")
   
   # Bad
   db_password = "my-secret-password"
   ```

2. **.gitignoreを活用する / Use .gitignore**
   
   以下のファイルは.gitignoreに含まれています：
   The following files are included in .gitignore:
   - `.env` - 環境変数ファイル / Environment variable files
   - `*.tfvars` - Terraform変数ファイル / Terraform variable files
   - `*.pem` - プライベートキー / Private keys
   - `*.key` - キーファイル / Key files

3. **AWS認証情報の管理 / Managing AWS Credentials**
   
   Terraform/AWSを使用する際は：
   When using Terraform/AWS:
   ```bash
   # AWS CLIの設定を使用（推奨）
   # Use AWS CLI configuration (recommended)
   aws configure
   
   # または環境変数を設定（値は環境から取得）
   # Or set environment variables (values from environment)
   export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id)"
   export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key)"
   ```

4. **Terraform変数の管理 / Managing Terraform Variables**
   
   機密情報を含む変数は`terraform.tfvars`ファイルに保存し、これは.gitignoreに含まれています：
   Variables with sensitive information should be stored in `terraform.tfvars` file, which is included in .gitignore:
   ```hcl
   # terraform/terraform.tfvars (NOT committed to git)
   # Example format (use actual values from your secure credential storage)
   db_password = "your-secure-password-here"
   api_key     = "your-api-key-here"
   ```

## 自動セキュリティスキャン / Automated Security Scanning

このリポジトリには自動的なシークレットスキャンが設定されています：

This repository has automated secret scanning configured:

### GitHub Actions ワークフロー / GitHub Actions Workflow

- **ファイル**: `.github/workflows/secret-scan.yml`
- **実行タイミング / Run Triggers**:
  - プッシュ時 (main, developブランチ) / On push (main, develop branches)
  - プルリクエスト時 / On pull requests
  - 毎日午前2時 (UTC) / Daily at 2:00 AM UTC
  - 手動実行 / Manual trigger

- **ツール / Tool**: [Gitleaks](https://github.com/gitleaks/gitleaks)

### ローカルでのスキャン / Local Scanning

開発者は、コミット前にローカルでスキャンを実行できます：

Developers can run scans locally before committing:

```bash
# Gitleaksのインストール / Install Gitleaks
# macOS
brew install gitleaks

# Linux
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.2/gitleaks_8.18.2_linux_x64.tar.gz
tar -xzf gitleaks_8.18.2_linux_x64.tar.gz
sudo mv gitleaks /usr/local/bin/

# Windows
# Download from https://github.com/gitleaks/gitleaks/releases

# スキャンの実行 / Run scan
gitleaks detect --source . --verbose
```

## 万が一、機密情報をコミットしてしまった場合 / If You Accidentally Commit Sensitive Information

1. **即座に対応する / Act Immediately**
   - コミットした認証情報を無効化・変更する / Revoke/rotate the committed credentials
   - セキュリティチームに報告する / Report to the security team

2. **履歴から削除する / Remove from History**
   ```bash
   # BFG Repo-Cleanerを使用 / Use BFG Repo-Cleaner
   # https://rtyley.github.io/bfg-repo-cleaner/
   
   # または / Or
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch PATH-TO-YOUR-FILE" \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **強制プッシュ / Force Push**
   ```bash
   git push origin --force --all
   ```

   ⚠️ **注意**: 強制プッシュはチームメンバーに影響を与えます。事前に通知してください。
   
   ⚠️ **Warning**: Force pushing affects team members. Notify them beforehand.

## セキュリティスキャン結果 / Security Scan Results

### 最新スキャン / Latest Scan

- **日付 / Date**: 2025-10-30
- **ツール / Tool**: Gitleaks v8.18.2
- **結果 / Result**: ✅ **機密情報なし / No secrets found**
- **スキャン範囲 / Scope**: 
  - 現在のファイル / Current files
  - Gitコミット履歴 / Git commit history

## 参考資料 / References

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
- [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
