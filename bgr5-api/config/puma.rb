# frozen_string_literal: true

# スレッド数の設定: 最小値と最大値 (環境変数から取得、またはデフォルト値を使用)
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

# ワーカー数の設定 (環境変数から取得、またはデフォルト値を使用)
workers ENV.fetch("WEB_CONCURRENCY", 1).to_i

# アプリケーションをプリロード
preload_app!

# ポート設定 - Cloud Run環境ではPORT環境変数を使用
port ENV.fetch("PORT", 8080).to_i

# 環境設定
environment ENV.fetch("RAILS_ENV", "development")

# 全てのインターフェースにバインド
bind "tcp://0.0.0.0:#{ENV.fetch("PORT", 8080)}"

# アプリケーション再起動のプラグイン
plugin :tmp_restart

# ワーカー起動時にデータベース接続を確立
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# ワーカー終了時にデータベース接続を切断
on_worker_shutdown do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# メモリ使用量を抑えるための設定
before_fork do
  GC.compact if defined?(GC) && GC.respond_to?(:compact)
end

# 初期化ログ
puts "===== Puma設定情報 ====="
puts "環境: #{ENV.fetch("RAILS_ENV", "development")}"
puts "ポート: #{ENV.fetch("PORT", 8080)} (Cloud Run環境ではこのポートが使用されます)"
puts "スレッド: #{min_threads_count}..#{max_threads_count}"
puts "ワーカー: #{ENV.fetch("WEB_CONCURRENCY", 1)}"
puts "======================= 