require "test_helper"

class SupplierTest < ActiveSupport::TestCase
  test "supports every approved company type" do
    assert_equal(
      %w[factory box_supplier print_shop design_studio fulfillment],
      Supplier.company_types.keys
    )
  end

  test "requires content and non-negative commercial values" do
    supplier = Supplier.new

    refute supplier.valid?
    %i[name specialization description regions services].each do |attribute|
      assert supplier.errors[attribute].any?, "expected #{attribute} to be required"
    end

    supplier = suppliers(:kraft_factory)
    supplier.minimum_order = -1
    supplier.unit_price_from = -0.01

    refute supplier.valid?
    assert supplier.errors[:minimum_order].any?
    assert supplier.errors[:unit_price_from].any?
  end

  test "serializes regions and services as arrays" do
    supplier = suppliers(:kraft_factory)

    assert_equal [ "Москва", "Московская область" ], supplier.regions
    assert_equal [ "Печать", "Вырубка" ], supplier.services
  end

  test "available includes active suppliers only" do
    assert_includes Supplier.available, suppliers(:kraft_factory)
    refute_includes Supplier.available, suppliers(:inactive_studio)
  end

  test "matches a region without case or surrounding whitespace" do
    supplier = suppliers(:kraft_factory)

    assert supplier.supports_region?("  москва ")
    refute supplier.supports_region?("Казань")
    refute supplier.supports_region?(nil)
  end

  test "connects to materials and uses its slug in URLs" do
    supplier = suppliers(:kraft_factory)

    assert_includes supplier.materials, materials(:microcorrugated)
    assert_equal "kraft-packaging", supplier.to_param
  end
end
