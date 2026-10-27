require "test_helper"

class PackagingEstimatorTest < ActiveSupport::TestCase
  test "reference candle box costs exactly 24 rubles per unit" do
    result = PackagingEstimator.call(**reference_attributes)

    assert_equal BigDecimal("24.00"), result.unit_price
    assert_equal BigDecimal("12000.00"), result.total_price
    assert_equal BigDecimal("21.12"), result.low_price
    assert_equal BigDecimal("28.08"), result.high_price
  end

  test "same inputs always produce the same result" do
    first = PackagingEstimator.call(**reference_attributes)
    second = PackagingEstimator.call(**reference_attributes)

    assert_equal first, second
  end

  test "larger quantities reduce the unit price" do
    small_run = PackagingEstimator.call(**reference_attributes.merge(quantity: 100))
    large_run = PackagingEstimator.call(**reference_attributes.merge(quantity: 1_000))

    assert_operator small_run.unit_price, :>, large_run.unit_price
  end

  test "material price factor affects the result" do
    micro = PackagingEstimator.call(**reference_attributes)
    craft = PackagingEstimator.call(**reference_attributes.merge(material: materials(:craft_cardboard)))

    assert_operator micro.unit_price, :>, craft.unit_price
  end

  test "fragility printing and extras add a surcharge" do
    base = PackagingEstimator.call(**reference_attributes)
    enhanced = PackagingEstimator.call(**reference_attributes.merge(
      fragile: true,
      print_option: "full_color",
      extras: %w[insert window varnish]
    ))

    assert_operator enhanced.unit_price, :>, base.unit_price
  end

  test "money is rounded to kopecks and breakdown sums to the unit price" do
    result = PackagingEstimator.call(**reference_attributes.merge(length_mm: 137, quantity: 333))

    assert_equal result.unit_price, result.unit_price.round(2)
    assert_equal result.unit_price, result.breakdown.values.sum
  end

  test "invalid numeric and categorical inputs return named errors" do
    invalid_cases = {
      length_mm: [ 0, -1, "text", 5_001 ],
      quantity: [ 0, -5, "many", 1_000_001 ],
      weight_grams: [ -1, "heavy", 100_001 ],
      print_option: [ "metallic" ],
      extras: [ [ "unknown" ] ]
    }

    invalid_cases.each do |attribute, values|
      values.each do |value|
        error = assert_raises(PackagingEstimator::InvalidInput) do
          PackagingEstimator.call(**reference_attributes.merge(attribute => value))
        end

        assert_includes error.errors.keys, attribute
      end
    end
  end

  private

  def reference_attributes
    {
      product_type: "Свечи в стекле",
      length_mm: 90,
      width_mm: 90,
      height_mm: 110,
      weight_grams: 0,
      fragile: false,
      material: materials(:microcorrugated),
      quantity: 500,
      region: "Москва",
      print_option: "none",
      extras: []
    }
  end
end
