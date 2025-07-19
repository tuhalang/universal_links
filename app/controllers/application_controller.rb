class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication helpers
  before_action :set_current_user

  private

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def current_user
    @current_user
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
  end

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "You must be an admin to access this page"
      redirect_to root_path
    end
  end

  def authorize_user_or_admin(resource)
    unless current_user&.admin? || resource.user == current_user
      flash[:alert] = "You can only access your own resources"
      redirect_to root_path
    end
  end

  # Make these methods available in views
  helper_method :current_user, :logged_in?
end
