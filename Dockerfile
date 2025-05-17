FROM node:20-alpine AS builder

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係のファイルをコピー
COPY package.json package-lock.json ./

# 依存関係をインストール
RUN npm ci

# ソースコードをコピー
COPY . .

# Node.jsのメモリ制限を緩和
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NEXT_TELEMETRY_DISABLED=1

# development用のビルド（より安定しているため）
ENV NODE_ENV=development
RUN npm run build

# 本番用環境設定
FROM node:20-alpine AS runner
WORKDIR /app

# 本番環境として設定
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1

# Next.jsが実行時に必要なファイルのみをコピー
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.js ./next.config.js

# ポートを公開
EXPOSE 3000

# 本番サーバーを起動
CMD ["npm", "start"] 