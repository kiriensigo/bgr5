#!/bin/bash
# wait-for-postgres.sh

set -e

# コマンドライン引数からパラメータを取得
host="${1:-localhost}"
port="${2:-5432}"
user="${3:-postgres}"
password="${4:-postgres}"
database="${5:-postgres}"

echo "Waiting for PostgreSQL to be ready on $host:$port..."
echo "User: $user, Database: $database"

# タイムアウト設定 - より長いタイムアウトに設定
max_retries=60
retry_interval=3

# データベースの存在確認と診断情報
check_connection() {
  echo "Checking for connection to PostgreSQL..."
  
  # さまざまな診断コマンドを実行
  
  # テレネットでポートが開いているか確認
  if command -v telnet >/dev/null 2>&1; then
    echo "Testing port with telnet:"
    echo quit | timeout 5 telnet "$host" "$port" || echo "Telnet failed - port might be closed"
  else
    echo "Telnet not available for port testing"
  fi
  
  # netcatでポートが開いているか確認
  if command -v nc >/dev/null 2>&1; then
    echo "Testing port with netcat:"
    nc -zvw3 "$host" "$port" || echo "Netcat failed - port might be closed"
  else
    echo "Netcat not available for port testing"
  fi
  
  # pg_isreadyを使ってPostgreSQLの状態を確認
  if command -v pg_isready >/dev/null 2>&1; then
    echo "Testing PostgreSQL readiness with pg_isready:"
    pg_isready -h "$host" -p "$port" -U "$user" -d "$database" -t 5 || echo "pg_isready failed - PostgreSQL might not be running"
  else
    echo "pg_isready not available"
  fi
  
  # psqlコマンドで直接接続を試みる
  echo "Testing PostgreSQL connection with psql:"
  PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "$database" -c "\l" || echo "Failed to list databases - PostgreSQL might be running but unreachable"
}

# PostgreSQLが準備できるまで待機
retries=0
until PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "$database" -c "SELECT 1" > /dev/null 2>&1; do
  retries=$((retries + 1))
  
  if [ $retries -ge $max_retries ]; then
    echo "Error: Failed to connect to PostgreSQL after $max_retries attempts."
    echo "Connection details:"
    echo "  Host: $host"
    echo "  Port: $port"
    echo "  User: $user"
    echo "  Database: $database"
    
    # 詳細な接続診断を実行
    check_connection
    
    # 存在しないデータベースの場合はpostgresデータベースに接続を試みる
    echo "Trying to connect to 'postgres' database instead..."
    PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "postgres" -c "SELECT 1" > /dev/null 2>&1 && {
      echo "Successfully connected to 'postgres' database!"
      echo "The specified database '$database' may not exist. Attempting to create it..."
      PGPASSWORD="$password" psql -h "$host" -p "$port" -U "$user" -d "postgres" -c "CREATE DATABASE $database;" && {
        echo "Successfully created database '$database'!"
        echo "PostgreSQL is ready!"
        exit 0
      } || {
        echo "Failed to create database '$database'. Check if user has necessary privileges."
      }
    } || {
      echo "Failed to connect to 'postgres' database as well. PostgreSQL might not be running or accessible."
    }
    
    # エラーでも続行する（docker-entrypointで処理）
    exit 1
  fi
  
  echo "Waiting for PostgreSQL to be ready... ($retries/$max_retries)"
  sleep $retry_interval
done

echo "PostgreSQL is ready!"
exit 0 