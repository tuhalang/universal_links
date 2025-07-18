class Click < ApplicationRecord
  belongs_to :dynamic_link

  # Validations
  validates :user_agent, presence: true
  validates :ip_address, presence: true

  # Scopes
  scope :recent, -> { order(clicked_at: :desc) }
  scope :today, -> { where(clicked_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(clicked_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(clicked_at: 1.month.ago..Time.current) }
  scope :by_platform, ->(platform) { where(device_type: platform) }
  scope :by_country, ->(country) { where(country: country) }

  # Callbacks
  before_validation :set_clicked_at, on: :create

  # Methods
  def mobile?
    %w[smartphone tablet].include?(device_type)
  end

  def desktop?
    device_type == "desktop"
  end

  def ios?
    os_name&.downcase == "ios"
  end

  def android?
    os_name&.downcase == "android"
  end

  private

  def set_clicked_at
    self.clicked_at = Time.current if clicked_at.blank?
  end
end
