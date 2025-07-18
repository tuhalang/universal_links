class DeviceDetectionService
  attr_reader :user_agent, :detector

  def initialize(user_agent)
    @user_agent = user_agent
    @detector = DeviceDetector.new(user_agent)
  end

  def device_info
    {
      device_type: device_type,
      os_name: os_name,
      os_version: os_version,
      browser_name: browser_name,
      browser_version: browser_version,
      is_mobile: mobile?,
      is_tablet: tablet?,
      is_desktop: desktop?,
      is_ios: ios?,
      is_android: android?,
      supports_universal_links: supports_universal_links?,
      supports_app_links: supports_app_links?
    }
  end

  def device_type
    return "smartphone" if detector.device_type == "smartphone"
    return "tablet" if detector.device_type == "tablet"
    "desktop"
  end

  def os_name
    detector.os_name
  end

  def os_version
    detector.os_full_version || detector.os_version || "Unknown"
  end

  def browser_name
    detector.name
  end

  def browser_version
    detector.full_version || "Unknown"
  end

  def mobile?
    detector.device_type == "smartphone"
  end

  def tablet?
    detector.device_type == "tablet"
  end

  def desktop?
    !mobile? && !tablet?
  end

  def ios?
    os_name&.downcase == "ios"
  end

  def android?
    os_name&.downcase == "android"
  end

  def supports_universal_links?
    return false unless ios?

    # Universal Links supported in iOS 9+ and Safari
    version = os_version.to_f
    version >= 9.0 && (safari? || in_app_browser_supporting_universal_links?)
  end

  def supports_app_links?
    return false unless android?

    # App Links supported in Android 6.0+ (API 23+)
    version = os_version.to_f
    version >= 6.0 && chrome_or_compatible?
  end

  def safari?
    browser_name&.downcase == "safari"
  end

  def chrome?
    browser_name&.downcase&.include?("chrome")
  end

  def chrome_or_compatible?
    chrome? || browser_name&.downcase&.include?("chromium")
  end

  def in_app_browser_supporting_universal_links?
    # Some in-app browsers support Universal Links
    # This is a simplified check - real implementation would be more sophisticated
    safari? || browser_name&.downcase&.include?("webkit")
  end

  def can_detect_app_installation?
    # Very limited - mostly we can't reliably detect app installation
    # This would be used for heuristics or JavaScript-based detection
    false
  end

  def recommended_strategy
    if ios? && supports_universal_links?
      :universal_link_with_fallback
    elsif android? && supports_app_links?
      :app_link_with_fallback
    elsif mobile? || tablet?
      :store_redirect_with_custom_scheme
    else
      :web_redirect
    end
  end

  def fingerprint
    # Create a simple device fingerprint for deferred deep linking
    # In production, this would be more sophisticated
    components = [
      device_type,
      os_name,
      os_version,
      browser_name,
      user_agent&.length.to_s
    ].compact

    Digest::SHA256.hexdigest(components.join("|"))[0..15]
  end
end
