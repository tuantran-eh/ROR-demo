require 'jwt'

class TokensController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(name: params[:name])
    if user&.authenticate(params[:password])
      token = generate_token(user)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid name or password' }, status: :unauthorized
    end
  end

  private

  def generate_token(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
