class LinksController < ApplicationController
  # Skip CSRF verification for API-like usage (smart links don't need forms)
  skip_before_action :verify_authenticity_token, only: [ :redirect ]
  before_action :find_dynamic_link, only: [ :redirect ]

  def redirect
    # Track the click for analytics
    track_click if @link.analytics_enabled?

    # Determine redirect strategy based on device
    device_service = DeviceDetectionService.new(request.user_agent)
    strategy = device_service.recommended_strategy
    device_info = device_service.device_info

    # Generate additional tracking parameters
    additional_params = {
      "ref" => request.referer&.split("/")&.last,
      "ua" => device_info[:browser_name]&.downcase,
      "v" => Time.current.strftime("%Y%m%d")
    }.compact

    case strategy
    when :universal_link_with_fallback
      handle_ios_redirect(device_service, device_info, additional_params)
    when :app_link_with_fallback
      handle_android_redirect(device_service, device_info, additional_params)
    when :store_redirect_with_custom_scheme
      handle_mobile_fallback(device_service, device_info, additional_params)
    when :web_redirect
      handle_web_redirect(device_info, additional_params)
    else
      enhanced_url = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "direct",
        additional_params: additional_params
      )
      redirect_to enhanced_url, status: :moved_permanently, allow_other_host: true
    end
  end

  private

  def find_dynamic_link
    @link = DynamicLink.active.find_by!(short_code: params[:short_code])
  rescue ActiveRecord::RecordNotFound
    render plain: "Link not found", status: :not_found
  end

  def track_click
    device_service = DeviceDetectionService.new(request.user_agent)
    device_info = device_service.device_info

    @link.clicks.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      referer: request.referer,
      device_type: device_info[:device_type],
      os_name: device_info[:os_name],
      os_version: device_info[:os_version],
      browser_name: device_info[:browser_name],
      browser_version: device_info[:browser_version],
      country: extract_country_from_ip(request.remote_ip)
    )
  end

  def handle_ios_redirect(device_service, device_info, additional_params)
    ios_config = @link.ios_config

    if ios_config.present?
      # Enhanced target URL with tracking parameters
      enhanced_target = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "ios_app",
        additional_params: additional_params
      )

      render_smart_redirect_page(
        primary_url: enhanced_target,
        fallback_url: ios_config.store_url,
        custom_scheme_url: ios_config.custom_scheme_url,
        platform: "ios"
      )
    else
      enhanced_url = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "ios_fallback",
        additional_params: additional_params
      )
      redirect_to enhanced_url, status: :moved_permanently, allow_other_host: true
    end
  end

  def handle_android_redirect(device_service, device_info, additional_params)
    android_config = @link.android_config

    if android_config.present?
      # Enhanced target URL with tracking parameters
      enhanced_target = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "android_app",
        additional_params: additional_params
      )

      render_smart_redirect_page(
        primary_url: enhanced_target,
        fallback_url: android_config.store_url,
        custom_scheme_url: android_config.custom_scheme_url,
        platform: "android"
      )
    else
      enhanced_url = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "android_fallback",
        additional_params: additional_params
      )
      redirect_to enhanced_url, status: :moved_permanently, allow_other_host: true
    end
  end

  def handle_mobile_fallback(device_service, device_info, additional_params)
    if device_service.ios? && @link.ios_config.present?
      ios_config = @link.ios_config

      # Enhanced target URL with tracking parameters
      enhanced_target = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "ios_mobile_fallback",
        additional_params: additional_params
      )

      render_smart_redirect_page(
        primary_url: enhanced_target,
        fallback_url: ios_config.store_url,
        custom_scheme_url: ios_config.custom_scheme_url,
        platform: "ios"
      )
    elsif device_service.android? && @link.android_config.present?
      android_config = @link.android_config

      # Enhanced target URL with tracking parameters
      enhanced_target = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "android_mobile_fallback",
        additional_params: additional_params
      )

      render_smart_redirect_page(
        primary_url: enhanced_target,
        fallback_url: android_config.store_url,
        custom_scheme_url: android_config.custom_scheme_url,
        platform: "android"
      )
    else
      enhanced_url = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "mobile_fallback",
        additional_params: additional_params
      )
      redirect_to enhanced_url, status: :moved_permanently, allow_other_host: true
    end
  end

  def handle_web_redirect(device_info, additional_params)
    web_config = @link.web_config

    if web_config.present?
      redirect_to web_config.redirect_url, status: :moved_permanently, allow_other_host: true
    else
      enhanced_url = @link.target_url_with_params(
        device_type: device_info[:device_type],
        source: "web",
        additional_params: additional_params
      )
      redirect_to enhanced_url, status: :moved_permanently, allow_other_host: true
    end
  end

  def render_smart_redirect_page(options = {})
    @redirect_options = {
      link: @link,
      primary_url: options[:primary_url],
      fallback_url: options[:fallback_url],
      custom_scheme_url: options[:custom_scheme_url],
      intent_url: options[:intent_url],
      platform: options[:platform],
      timeout: 2500 # milliseconds to wait before fallback
    }

    render :smart_redirect, layout: false
  end

  def extract_country_from_ip(ip_address)
    # Simplified country detection - in production use a GeoIP service
    # For now, just return nil
    nil
  end
end
