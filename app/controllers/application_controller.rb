class ApplicationController < ActionController::API
  before_action :auth

  def auth
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      user_id = TokenUtils.decode(header)['user_id']
      @current_user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
