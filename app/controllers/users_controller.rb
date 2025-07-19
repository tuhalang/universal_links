class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update ]
  before_action :require_login, except: [ :new, :create ]
  before_action :authorize_user_access, only: [ :show, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Universal Links, #{@user.name}!"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_links = @user.dynamic_links.recent.includes(:ios_config, :android_config, :web_config)
    @total_links = @user_links.count
    @total_clicks = @user.dynamic_links.joins(:clicks).count
    @links_this_month = @user_links.where(created_at: 1.month.ago..Time.current).count
  end

  def edit
  end

  def update
    if @user.update(user_params.except(:role))
      flash[:notice] = "Profile updated successfully"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user_access
    unless current_user&.admin? || @user == current_user
      flash[:alert] = "You can only access your own profile"
      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end
end
