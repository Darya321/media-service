class Inquiry < ApplicationRecord
  EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  belongs_to :supplier, optional: true
  belongs_to :material

  enum :status, {
    submitted: 0,
    reviewing: 1,
    contacted: 2,
    closed: 3
  }

  serialize :extras, coder: JSON, type: Array

  before_validation :normalize_email

  validates :email,
    presence: true,
    format: { with: EMAIL_PATTERN }
  validates :product_type, :region, presence: true
  validates :length_mm, :width_mm, :height_mm,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5_000 }
  validates :quantity,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1_000_000 }
  validates :weight_grams,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :budget,
    :estimated_unit_price,
    :estimated_total_price,
    :estimated_low_price,
    :estimated_high_price,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true

  def calculator_attributes
    {
      product_type: product_type,
      length_mm: length_mm,
      width_mm: width_mm,
      height_mm: height_mm,
      weight_grams: weight_grams,
      fragile: fragile,
      material: material,
      quantity: quantity,
      region: region,
      print_option: print_option,
      extras: extras
    }
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
