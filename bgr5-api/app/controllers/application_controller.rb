class ApplicationController < ActionController::API
  # 基本的なエラーハンドリング
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  
  private
  
  def handle_standard_error(exception)
    Rails.logger.error("Unexpected error: #{exception.message}\n#{exception.backtrace.join("\n")}")
    render json: { error: 'Internal server error', details: exception.message }, status: :internal_server_error
  end
  
  def handle_not_found(exception)
    render json: { error: 'Record not found', details: exception.message }, status: :not_found
  end
  
  def handle_parameter_missing(exception)
    render json: { error: 'Missing required parameter', details: exception.message }, status: :bad_request
  end
end 