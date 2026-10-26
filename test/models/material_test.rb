require "test_helper"

class MaterialTest < ActiveSupport::TestCase
  test "requires content, a unique slug, and a positive price factor" do
    material = Material.new

    refute material.valid?
    %i[name summary description use_cases].each do |attribute|
      assert material.errors[attribute].any?, "expected #{attribute} to be required"
    end

    duplicate = materials(:microcorrugated).dup
    duplicate.name = "Another material"

    refute duplicate.valid?
    assert duplicate.errors[:slug].any?

    material = materials(:microcorrugated)
    material.price_factor = nil

    refute material.valid?
    assert material.errors[:price_factor].any?

    material.price_factor = 0

    refute material.valid?
    assert material.errors[:price_factor].any?
  end

  test "restricts every comparison score to one through five" do
    material = materials(:microcorrugated)

    %i[strength_score print_score eco_score cost_score].each do |attribute|
      material.public_send("#{attribute}=", 0)
      refute material.valid?, "expected #{attribute}=0 to be invalid"
      assert material.errors[attribute].any?

      material.public_send("#{attribute}=", 6)
      refute material.valid?, "expected #{attribute}=6 to be invalid"
      assert material.errors[attribute].any?

      material.public_send("#{attribute}=", 3)
    end
  end

  test "generates a stable URL slug" do
    material = Material.new(
      name: "Glass Packaging",
      summary: "Summary",
      description: "Description",
      use_cases: "Bottles",
      strength_score: 4,
      print_score: 2,
      eco_score: 5,
      cost_score: 2,
      price_factor: 1.4
    )

    assert material.valid?
    assert_equal "glass-packaging", material.slug
    assert_equal "glass-packaging", material.to_param
  end

  test "connects to suppliers through the join model" do
    material = materials(:microcorrugated)

    assert_includes material.suppliers, suppliers(:kraft_factory)
  end
end
