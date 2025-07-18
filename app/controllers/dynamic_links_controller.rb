class DynamicLinksController < ApplicationController
  before_action :set_dynamic_link, only: [ :show, :edit, :update, :destroy, :analytics, :toggle_active ]
  before_action :parse_auto_params, only: [ :create, :update ]

  def index
    @dynamic_links = DynamicLink.recent.includes(:ios_config, :android_config, :web_config)
    @total_links = @dynamic_links.count
    @total_clicks = Click.count
    @links_today = @dynamic_links.joins(:clicks).where(clicks: { clicked_at: Date.current.beginning_of_day..Date.current.end_of_day }).distinct.count
  end

  def show
    @recent_clicks = @dynamic_link.recent_clicks(7).recent.limit(10)
    @clicks_by_platform = @dynamic_link.clicks_by_platform
    @clicks_by_day = @dynamic_link.clicks.group_by_day(:clicked_at, last: 7).count
  end

  def new
    @dynamic_link = DynamicLink.new
    @dynamic_link.build_ios_config
    @dynamic_link.build_android_config
    @dynamic_link.build_web_config
  end

  def create
    @dynamic_link = DynamicLink.new(dynamic_link_params)

    if @dynamic_link.save
      redirect_to @dynamic_link, notice: "Dynamic link was successfully created."
    else
      @dynamic_link.build_ios_config unless @dynamic_link.ios_config
      @dynamic_link.build_android_config unless @dynamic_link.android_config
      @dynamic_link.build_web_config unless @dynamic_link.web_config
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dynamic_link.build_ios_config unless @dynamic_link.ios_config
    @dynamic_link.build_android_config unless @dynamic_link.android_config
    @dynamic_link.build_web_config unless @dynamic_link.web_config
  end

  def update
    if @dynamic_link.update(dynamic_link_params)
      redirect_to @dynamic_link, notice: "Dynamic link was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dynamic_link.destroy
    redirect_to dynamic_links_url, notice: "Dynamic link was successfully deleted."
  end

  def analytics
    @clicks_by_day = @dynamic_link.clicks.group_by_day(:clicked_at, last: 30).count
    @clicks_by_platform = @dynamic_link.clicks.group(:device_type).count
    @clicks_by_browser = @dynamic_link.clicks.group(:browser_name).count
    @clicks_by_os = @dynamic_link.clicks.group(:os_name).count
    @clicks_by_country = @dynamic_link.clicks.where.not(country: nil).group(:country).count
    @recent_clicks = @dynamic_link.clicks.recent.limit(50)
  end

  def toggle_active
    @dynamic_link.update(active: !@dynamic_link.active?)
    redirect_to @dynamic_link, notice: "Link #{@dynamic_link.active? ? 'activated' : 'deactivated'} successfully."
  end

  private

  def set_dynamic_link
    @dynamic_link = DynamicLink.find(params[:id])
  end

  def parse_auto_params
    if params[:dynamic_link][:auto_params].present?
      begin
        parsed_params = JSON.parse(params[:dynamic_link][:auto_params])
        params[:dynamic_link][:auto_params] = parsed_params
      rescue JSON::ParserError
        # If JSON parsing fails, set to empty hash
        params[:dynamic_link][:auto_params] = {}
      end
    end
  end

  def dynamic_link_params
    params.require(:dynamic_link).permit(
      :title, :description, :target_url, :short_code,
      :social_title, :social_description, :social_image_url,
      :active, :analytics_enabled, :created_by,
      :enable_utm_tracking, :enable_device_params, :auto_params,
      ios_config_attributes: [
        :app_store_id, :bundle_identifier, :custom_scheme,
        :app_store_url, :fallback_url
      ],
      android_config_attributes: [
        :package_name, :play_store_url, :custom_scheme,
        :fallback_url
      ],
      web_config_attributes: [
        :desktop_url, :fallback_url
      ]
    )
  end
end
