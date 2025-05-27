class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

   
    if token.blank?
      return render json: { errors: ['Missing token'] }, status: :unauthorized
    end

    
    if BlacklistedToken.exists?(token: token)
      return render json: { errors: ['Token has been revoked'] }, status: :unauthorized
    end

    
    decoded = JsonWebToken.decode(token)
    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    end

    
    render json: { errors: ['Unauthorized'] }, status: :unauthorized unless @current_user
  end
end
