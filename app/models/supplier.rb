class Supplier < ApplicationRecord
  include HasSlug

  has_many :supplier_materials, dependent: :destroy
  has_many :materials, through: :supplier_materials
  has_many :inquiries, dependent: :nullify
  has_many :posts, dependent: :nullify

  enum :company_type, {
    factory: 0,
    box_supplier: 1,
    print_shop: 2,
    design_studio: 3,
    fulfillment: 4
  }

  serialize :regions, coder: JSON, type: Array
  serialize :services, coder: JSON, type: Array

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :specialization, :description, :regions, :services, presence: true
  validates :minimum_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :unit_price_from, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(active: true) }

  def slug_source
    name
  end

  def supports_region?(region)
    candidate = region.to_s.strip
    return false if candidate.blank?

    regions.any? { |available_region| available_region.casecmp?(candidate) }
  end
end
