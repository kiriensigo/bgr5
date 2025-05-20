module Api
  module V1
    class ReviewsController < ApplicationController
      def index
        begin
          # データベース接続テスト
          db_status = ActiveRecord::Base.connection.execute("SELECT 1").to_a.length == 1 ? "connected" : "error"
        rescue => e
          db_status = "error: #{e.message}"
        end

        render json: { 
          message: 'Reviews API is working',
          timestamp: Time.current,
          rails_env: Rails.env, 
          database_status: db_status
        }
      end
      
      def show
        render json: { 
          message: 'Review details API is working', 
          id: params[:id], 
          timestamp: Time.current 
        }
      end
      
      def create
        params_info = params.permit(:game_id, :comment, :rating).to_h
        render json: { 
          message: 'Review creation API is working', 
          timestamp: Time.current,
          received_params: params_info.presence || "No parameters provided"
        }
      end
    end
  end
end 