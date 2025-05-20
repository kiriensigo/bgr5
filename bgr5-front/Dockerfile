FROM node:20-alpine

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係のファイルをコピー
COPY package.json ./

# 依存関係をインストール
RUN npm install

# ソースコードをコピー
COPY . .

# Node.jsのメモリ制限を緩和
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NEXT_TELEMETRY_DISABLED=1

# アプリケーションをビルド
# エラーを無視せず、ビルドが成功するようにする
RUN npm run build

# 本番環境として設定
ENV NODE_ENV=production
ENV PORT=3000

# ポートを公開
EXPOSE 3000

# 本番サーバーを起動
CMD ["npm", "start"] 