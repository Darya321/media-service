require "test_helper"

class SupplierMaterialTest < ActiveSupport::TestCase
  test "rejects the same material twice for one supplier" do
    duplicate = SupplierMaterial.new(
      supplier: suppliers(:kraft_factory),
      material: materials(:microcorrugated)
    )

    refute duplicate.valid?
    assert duplicate.errors[:material_id].any?
  end
end
