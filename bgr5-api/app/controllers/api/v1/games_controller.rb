module Api
  module V1
    class GamesController < ApplicationController
      def index
        begin
          # データベース接続テスト
          db_status = ActiveRecord::Base.connection.execute("SELECT 1").to_a.length == 1 ? "connected" : "error"
        rescue => e
          db_status = "error: #{e.message}"
        end

        render json: { 
          message: 'Games API is working',
          timestamp: Time.current,
          rails_env: Rails.env, 
          ruby_version: RUBY_VERSION,
          rails_version: Rails.version,
          database_status: db_status,
          database_config: {
            host: ENV['DATABASE_HOST'],
            port: ENV['DATABASE_PORT'],
            database: ENV['DATABASE_NAME'],
            adapter: ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
          }
        }
      end
      
      def show
        render json: { 
          message: 'Game details API is working', 
          id: params[:id], 
          timestamp: Time.current,
          request_info: {
            ip: request.remote_ip,
            user_agent: request.user_agent
          }
        }
      end
      
      def create
        params_info = params.permit(:name, :description).to_h
        render json: { 
          message: 'Game creation API is working', 
          timestamp: Time.current,
          received_params: params_info.presence || "No parameters provided"
        }
      end
    end
  end
end 