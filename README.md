# BGr5 - ボードゲームレビューアプリケーション

ボードゲームのレビューと共有のためのウェブアプリケーション（BGr4 のクローン）

## 構成

- フロントエンド:
  - bgr5-front: Next.js 14 + MUI
  - bgr5-front-simple: 簡易版フロントエンド
- バックエンド: bgr5-api (Ruby on Rails)
- データベース: PostgreSQL

## 開発環境のセットアップ

### 必要条件

- Node.js 18 以上
- Ruby 3.3.0
- PostgreSQL 15
- Docker (オプション)

### フロントエンドの起動

```bash
# フロントエンドのセットアップ
cd bgr5-front
npm install
npm run dev
```

### バックエンドの起動

```bash
# バックエンドのセットアップ
cd bgr5-api
bundle install
rails db:create db:migrate db:seed
rails s
```

### Docker Compose での起動

```bash
# Docker Composeで全環境を起動
docker-compose up -d
```

## デプロイ

Google Cloud Run + Cloud SQL を使用したデプロイ方法：

```bash
# フロントエンドのデプロイ
cd bgr5-front
gcloud builds submit --config cloudbuild.yaml

# バックエンドのデプロイ
cd bgr5-api
gcloud builds submit --config cloudbuild.yaml
```
