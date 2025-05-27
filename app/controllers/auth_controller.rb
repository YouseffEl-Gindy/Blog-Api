class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:signup, :login]


  def signup
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: user }, status: :ok
    else
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  def logout
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      BlacklistedToken.create(token: token)
      render json: { message: "Logged out successfully" }
    else
      render json: { error: "No token provided" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :image)
  end
end
