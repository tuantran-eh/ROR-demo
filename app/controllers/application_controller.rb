class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_with_token, if: :api_request?

  rescue_from Pundit::NotAuthorizedError do
    redirect_to '/login'
  end

  private

  def authenticate_with_token
    header = request.headers['Authorization']
    token = header.split(' ').last if header&.start_with?('Bearer ')
    Rails.logger.debug("Authorization header: #{header}, token: #{token}")
    begin
      payload = JWT.decode(token, Rails.application.secret_key_base)[0]
      @current_user = User.find(payload['user_id'])
    rescue
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def api_request?
    request.format.json?
  end

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def not_found
    redirect_to '/404_page', status: :not_found
  end
end
