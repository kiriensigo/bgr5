# frozen_string_literal: true

# Pumaの設定を環境変数から取得または設定
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 10 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# 無料プランではサーバースレッド数を少なめに設定
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# ポート設定
port ENV.fetch("PORT") { 8080 }

# 環境設定
environment ENV.fetch("RAILS_ENV") { "development" }

# デプロイ環境でのバインディング設定
if ENV["RAILS_ENV"] == "production"
  bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 8080 }}"
end

# コードが事前ロードされるように設定
preload_app!

# 再起動戦略
restart_command 'bundle exec puma'

# 正常にシャットダウンするための時間を設定
worker_timeout 60 if ENV["RAILS_ENV"] == "production"

# ワーカーのブート時にシグナルハンドラをインストール
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  
  # GCのチューニング
  GC.disable if defined?(GC)
end

# ワーカープロセスの状態確認
before_fork do
  # 必要なら環境変数や設定を事前に設定
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# プロセスを再起動する前にアプリケーションを正常にシャットダウン
on_worker_shutdown do
  # トランザクションのクリーンアップなど、シャットダウン時に実行する処理
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  # GCを有効化してメモリ解放
  GC.enable if defined?(GC)
  GC.start if defined?(GC)
end

# ワーカーの再起動を可能にするための設定
plugin :tmp_restart

# 低メモリマシン向け設定
if ENV["LOW_MEMORY_MODE"] == "true"
  before_fork do
    GC.compact if defined?(GC) && GC.respond_to?(:compact)
  end
end 