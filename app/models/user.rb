class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Associations
  has_many :dynamic_links, dependent: :destroy

  # Role enumeration
  enum :role, { user: 0, admin: 1 }, default: :user

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Callbacks
  before_save :normalize_email

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_role, ->(role) { where(role: role) }

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
