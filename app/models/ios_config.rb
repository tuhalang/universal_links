class IosConfig < ApplicationRecord
  belongs_to :dynamic_link

  # Validations
  validates :app_store_id, presence: true, format: { with: /\A\d+\z/, message: "must be a numeric App Store ID" }
  validates :bundle_identifier, presence: true, format: { with: /\A[a-zA-Z0-9.-]+\z/, message: "invalid bundle identifier format" }
  validates :custom_scheme, presence: true
  validates :app_store_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[https]) }, allow_blank: true
  validates :fallback_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  # Methods
  def custom_scheme_url(path = nil)
    base = "#{custom_scheme}://"
    path.present? ? "#{base}#{path}" : base
  end

  def store_url
    app_store_url.presence || "https://apps.apple.com/app/id#{app_store_id}"
  end
end
