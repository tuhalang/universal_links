class AndroidConfig < ApplicationRecord
  belongs_to :dynamic_link

  # Validations
  validates :package_name, presence: true, format: { with: /\A[a-zA-Z0-9._]+\z/, message: "invalid package name format" }
  validates :play_store_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[https]) }, allow_blank: true
  validates :custom_scheme, presence: true
  validates :fallback_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  # Methods
  def custom_scheme_url(path = nil)
    base = "#{custom_scheme}://"
    path.present? ? "#{base}#{path}" : base
  end

  def store_url
    play_store_url.presence || "https://play.google.com/store/apps/details?id=#{package_name}"
  end
end
