Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => proc { [200, {}, ["OK"]] }
  get "ping" => proc { [200, {}, ["pong"]] }
  get "/" => proc { [200, {"Content-Type" => "application/json"}, [{status: "API is running", env: Rails.env, time: Time.now}.to_json]] }
  
  # 詳細なヘルスチェック
  get "health/detailed" => proc { 
    begin
      db_status = ActiveRecord::Base.connection.execute("SELECT 1").to_a.length == 1 ? "ok" : "error"
    rescue => e
      db_status = "error: #{e.message}"
    end
    
    [200, {"Content-Type" => "application/json"}, [
      {
        status: "running",
        environment: Rails.env,
        time: Time.now,
        ruby_version: RUBY_VERSION,
        rails_version: Rails.version,
        database: db_status
      }.to_json
    ]]
  }

  # APIのルーティング
  namespace :api do
    namespace :v1 do
      resources :games, only: [:index, :show, :create]
      resources :reviews, only: [:index, :show, :create]
    end
  end
  
  # ルートパスへのアクセスはヘルスチェックと同様の応答を返す
  root to: proc { [200, {'Content-Type' => 'text/plain'}, ['BGR5 API is running!']] }
end 