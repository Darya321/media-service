class Material < ApplicationRecord
  include HasSlug

  has_many :supplier_materials, dependent: :destroy
  has_many :suppliers, through: :supplier_materials

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :summary, :description, :use_cases, presence: true
  validates :price_factor, numericality: { greater_than: 0 }
  validates :strength_score, :print_score, :eco_score, :cost_score,
    numericality: { only_integer: true, in: 1..5 }

  def slug_source
    name
  end
end
