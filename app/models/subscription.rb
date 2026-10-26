class Subscription < ApplicationRecord
  EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  before_validation :normalize_email

  validates :email,
    presence: true,
    format: { with: EMAIL_PATTERN },
    uniqueness: { case_sensitive: false }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
