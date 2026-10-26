class SupplierMaterial < ApplicationRecord
  belongs_to :supplier
  belongs_to :material

  validates :material_id, uniqueness: { scope: :supplier_id }
end
