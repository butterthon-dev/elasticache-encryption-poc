# backend

Django + DRF の検証用API。

## ローカル開発

```bash
docker compose up
```

- API: http://localhost:8000
- ヘルスチェック: http://localhost:8000/healthz
- Swagger UI: http://localhost:8000/docs

環境変数は `backend/.env` から読み込む（`env_vars.py` を参照）。

## デプロイ

`main` ブランチへの push（`backend/**` の変更時）または手動実行で
`.github/workflows/deploy-backend.yml` が動き、以下を実行する。

1. OIDC で AWS のデプロイ用ロールを Assume
2. `backend/Dockerfile` をビルドして ECR に push（タグは `<commit sha>` と `latest`）
3. `backend/aws/task-definition/task.json` のイメージを push したイメージに差し替えて新しいリビジョンを登録
4. ECS サービスを更新し、安定するまで待機

### タスク定義のプレースホルダー

`task.json` にはアカウントIDを含めないため、以下のプレースホルダーをワークフロー内で置換している。

| プレースホルダー | 置換値 |
|---|---|
| `__AWS_ACCOUNT_ID__` | Assume したロールのアカウントID |
| `__AWS_REGION__` | ワークフローの `AWS_REGION` |

### 初回セットアップ

1. Terraform を適用して ECR・デプロイ用ロール・OIDC プロバイダーを作成する

   ```bash
   cd infra/envs/dev
   terraform init
   terraform apply
   ```

   OIDC プロバイダー（`token.actions.githubusercontent.com`）はアカウント全体で共有されるリソースのため、
   このスタックでは管理せずデータソースで参照する。アカウント内に存在しない場合は事前に作成が必要。

2. 出力されたロール ARN を GitHub のリポジトリシークレット `AWS_DEPLOY_ROLE_ARN` に登録する

   ```bash
   terraform output github_actions_deploy_role_arn
   ```

3. `DJANGO_SECRET` を SSM パラメータストアに投入する

   Terraform ではプレースホルダー値のみを作成し、値の変更は管理対象外（`ignore_changes`）にしているため、
   実際の値は AWS CLI で投入する。

   ```bash
   aws ssm put-parameter \
     --name "$(terraform output -raw backend_django_secret_parameter_name)" \
     --type SecureString \
     --value '<Djangoのシークレットキー>' \
     --overwrite
   ```

### 未対応・注意点

- ElastiCache（Redis）が未作成のため、`task.json` の `REDIS_HOST` はプレースホルダー（`localhost`）。
  作成後に実際のエンドポイントへ差し替える（`/items` は Redis 接続が必要）。
- コンテナの起動コマンドは `manage.py runserver` のまま（開発サーバー）。本番相当の構成では WSGI サーバーに差し替える。
