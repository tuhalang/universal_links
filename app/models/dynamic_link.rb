class DynamicLink < ApplicationRecord
  # Associations
  has_one :ios_config, dependent: :destroy
  has_one :android_config, dependent: :destroy
  has_one :web_config, dependent: :destroy
  has_many :clicks, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :ios_config, :android_config, :web_config,
                                allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :short_code, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows letters, numbers, hyphens and underscores" }
  validates :target_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :social_title, length: { maximum: 60 }, allow_blank: true
  validates :social_description, length: { maximum: 160 }, allow_blank: true

  # Serialization
  serialize :auto_params, coder: JSON

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :generate_short_code, on: :create
  before_validation :set_defaults, on: :create

  # Methods
  def short_url
    domain = Rails.application.config.app_domain ||
             Rails.application.config.action_mailer.default_url_options[:host] ||
             "localhost:3000"
    "#{domain.start_with?('http') ? domain : "http://#{domain}"}/#{short_code}"
  end

  def target_url_with_params(device_type: nil, source: nil, campaign: nil, additional_params: {})
    return target_url if target_url.blank?

    uri = URI.parse(target_url)
    existing_params = URI.decode_www_form(uri.query || "").to_h

    # Build auto-generated parameters based on settings
    auto_generated = {}

    # UTM tracking parameters (if enabled)
    if enable_utm_tracking != false # Default to true if not set
      auto_generated.merge!({
        "utm_source" => source || "dynamic_link",
        "utm_medium" => "referral",
        "utm_campaign" => campaign || title.parameterize,
        "utm_content" => short_code
      })
    end

    # Device and system parameters (if enabled)
    if enable_device_params != false # Default to true if not set
      auto_generated.merge!({
        "dl_device" => device_type,
        "dl_timestamp" => Time.current.to_i.to_s,
        "dl_id" => id.to_s
      })
    end

    # Custom auto parameters from configuration
    if auto_params.present? && auto_params.is_a?(Hash)
      auto_generated.merge!(auto_params.stringify_keys)
    end

    # Remove nil/empty values
    auto_generated = auto_generated.compact.reject { |k, v| v.to_s.strip.empty? }

    # Merge all parameters (additional_params override auto_generated which override existing)
    all_params = existing_params.merge(auto_generated).merge(additional_params.stringify_keys)

    # Remove nil values
    all_params = all_params.reject { |k, v| v.nil? || v.to_s.strip.empty? }

    # Build final URL
    uri.query = URI.encode_www_form(all_params) if all_params.any?
    uri.to_s
  end

  def total_clicks
    clicks.count
  end

  def recent_clicks(days = 7)
    clicks.where(clicked_at: days.days.ago..Time.current)
  end

  def clicks_by_platform
    clicks.group(:device_type).count
  end

  private

  def generate_short_code
    return if short_code.present?

    loop do
      self.short_code = SecureRandom.alphanumeric(8)
      break unless DynamicLink.exists?(short_code: short_code)
    end
  end

  def set_defaults
    self.active = true if active.nil?
    self.analytics_enabled = true if analytics_enabled.nil?
    self.enable_utm_tracking = true if enable_utm_tracking.nil?
    self.enable_device_params = true if enable_device_params.nil?
    self.auto_params = {} if auto_params.nil?
  end
end
