# frozen_string_literal: true

# デバッグ情報の出力
Rails.logger.info "CORS設定を初期化します"
cors_origins = ENV.fetch('CORS_ORIGINS', '*').split(',').map(&:strip)
Rails.logger.info "許可されるオリジン: #{cors_origins.inspect}"

# CORSを設定し、クロスオリジンリクエストを許可するためのミドルウェア設定
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 環境変数から許可するオリジンを取得（カンマで区切られた複数のオリジンをサポート）
    origins ENV.fetch('CORS_ORIGINS', '*').split(',').map(&:strip)

    # リソースとHTTPリクエストの設定
    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true,
             expose: %w[access-token expiry token-type uid client authorization],
             max_age: 86400 # 24時間キャッシュを許可
  end
  
  # 本番環境での警告ログ
  if Rails.env.production? && ENV.fetch('CORS_ORIGINS', '*').include?('*')
    Rails.logger.warn "警告: 本番環境で '*' ワイルドカードオリジンが使用されています。これはセキュリティリスクとなる可能性があります。"
  end
end

Rails.logger.info "CORS設定が完了しました" 