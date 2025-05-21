# frozen_string_literal: true

# デフォルトのスレッド数: 最小値と最大値 (環境変数から、またはデフォルト値)
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# ワーカー数の設定 (環境変数から、またはデフォルト値)
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# ワーカーごとのスレッド数をプリロードするための設定
preload_app!

# ポート設定 (環境変数から取得、またはデフォルト8080)
port ENV.fetch("PORT") { 8080 }

# 環境設定
environment ENV.fetch("RAILS_ENV") { "development" }

# 本番環境の場合、全てのインターフェースにバインドする
if ENV['RAILS_ENV'] == 'production'
  bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 8080 }}"
end

# アプリケーションを再起動する方法の定義
plugin :tmp_restart

# ワーカー起動時にデータベース接続を管理
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# ワーカー終了時にクリーンアップ
on_worker_shutdown do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# 低メモリモードの設定
before_fork do
  # メモリに優しい設定を有効にする
  GC.compact if defined?(GC) && GC.respond_to?(:compact)
end 