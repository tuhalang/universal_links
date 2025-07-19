class ApplicationController < ActionController::Base
  # Skip CSRF verification for API-like usage (smart links don't need forms)
  skip_before_action :verify_authenticity_token
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
