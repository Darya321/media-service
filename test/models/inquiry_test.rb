require "test_helper"

class InquiryTest < ActiveSupport::TestCase
  test "requires contact, product, dimensions, material, quantity, and region" do
    inquiry = Inquiry.new

    refute inquiry.valid?
    %i[email product_type length_mm width_mm height_mm material quantity region].each do |attribute|
      assert inquiry.errors[attribute].any?, "expected #{attribute} to be required"
    end
  end

  test "rejects a malformed contact email" do
    inquiry = inquiries(:candle_boxes)
    inquiry.email = "buyer@invalid"

    refute inquiry.valid?
    assert inquiry.errors[:email].any?
  end

  test "rejects non-positive dimensions and quantity" do
    inquiry = inquiries(:candle_boxes)

    %i[length_mm width_mm height_mm quantity].each do |attribute|
      original = inquiry.public_send(attribute)
      inquiry.public_send("#{attribute}=", 0)

      refute inquiry.valid?, "expected #{attribute}=0 to be invalid"
      assert inquiry.errors[attribute].any?

      inquiry.public_send("#{attribute}=", original)
    end
  end

  test "allows a general inquiry without a supplier" do
    inquiry = inquiries(:candle_boxes).dup
    inquiry.supplier = nil

    assert inquiry.valid?
  end

  test "serializes extras and exposes approved processing states" do
    inquiry = inquiries(:candle_boxes)
    inquiry.extras = [ "window", "insert" ]
    inquiry.save!

    assert_equal [ "window", "insert" ], inquiry.reload.extras
    assert_equal %w[submitted reviewing contacted closed], Inquiry.statuses.keys
  end

  test "returns the exact calculator input contract" do
    inquiry = inquiries(:candle_boxes)

    assert_equal(
      {
        product_type: "Свечи в стекле",
        length_mm: 90,
        width_mm: 90,
        height_mm: 110,
        weight_grams: 320,
        fragile: true,
        material: materials(:microcorrugated),
        quantity: 500,
        region: "Москва",
        print_option: "none",
        extras: []
      },
      inquiry.calculator_attributes
    )
  end

  test "belongs to the selected supplier when one is present" do
    inquiry = inquiries(:candle_boxes)

    assert_equal suppliers(:kraft_factory), inquiry.supplier
    assert_includes suppliers(:kraft_factory).inquiries, inquiry
    assert_includes materials(:microcorrugated).inquiries, inquiry
  end
end
