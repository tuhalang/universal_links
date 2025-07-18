class WebConfig < ApplicationRecord
  belongs_to :dynamic_link

  # Validations
  validates :desktop_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :fallback_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  # Methods
  def redirect_url
    desktop_url.presence || fallback_url.presence || dynamic_link.target_url
  end
end
