class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Skip CSRF protection for API requests
  protect_from_forgery with: :null_session

  # Add authentication token handling
  before_action :authenticate_user_from_token!

  private

  def json_request?
    request.format.json?
  end

  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      user = User.find_by(authentication_token: token)
      if user
        sign_in user, store: false
      end
    end
  end
end
