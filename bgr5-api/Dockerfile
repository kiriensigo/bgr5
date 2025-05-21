# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t bgr5_api .
# docker run -d -p 8080:8080 -e RAILS_MASTER_KEY=<value from config/master.key> --name bgr5_api bgr5_api

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# 必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    netcat-openbsd \
    dnsutils \
    iputils-ping \
    telnet \
    procps \
    vim-tiny \
    lsof \
    htop \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# jemallocをpreloadして性能向上
ENV LD_PRELOAD="libjemalloc.so.2"

# 環境変数の設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1" \
    DATABASE_URL="postgres://postgres:postgres@35.200.15.8:5432/bgr5_production" \
    DATABASE_HOST="35.200.15.8" \
    DATABASE_PORT="5432" \
    POSTGRES_USER="postgres" \
    POSTGRES_PASSWORD="postgres" \
    DATABASE_NAME="bgr5_production" \
    MALLOC_ARENA_MAX=2 \
    WEB_CONCURRENCY=2 \
    RAILS_MAX_THREADS=10

# gemをインストールするステージ
FROM base AS gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile ./
# Gemfile.lockが存在しない場合は生成し、インストールする
RUN bundle lock --no-color || true && \
    bundle config set --local without 'development test' && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# 開発時の高速化用にbootsnapをプリコンパイル
FROM gems AS build
RUN bundle exec bootsnap precompile --gemfile || true

# アプリケーションをコピー
COPY . .

# アプリケーションのコードをプリコンパイル
RUN bundle exec bootsnap precompile app/ lib/ || true

# シェルスクリプトの準備
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# 最終的なイメージを作成
FROM base
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# PostgreSQL待機スクリプトをコピー
COPY ./bin/wait-for-postgres.sh /usr/bin/
RUN chmod +x /usr/bin/wait-for-postgres.sh

# Rails特有の設定
RUN mkdir -p /rails/tmp/pids && \
    mkdir -p /rails/tmp/cache && \
    mkdir -p /rails/log && \
    touch /rails/log/production.log && \
    chown -R 1000:1000 /rails/log && \
    chown -R 1000:1000 /rails/tmp

# 非rootユーザーを作成
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 8080
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
