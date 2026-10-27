require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  test "new accepts calculator values as display defaults" do
    get new_inquiry_path, params: valid_attributes.merge(supplier_id: suppliers(:kraft_factory).id)

    assert_response :success
    assert_select "input[name='inquiry[quantity]'][value='500']"
    assert_select "input[name='inquiry[supplier_id]'][value='#{suppliers(:kraft_factory).id}']"
    assert_select "option[value='microcorrugated-cardboard'][selected]"
  end

  test "creates a general inquiry with a fresh server estimate" do
    assert_difference -> { Inquiry.count }, 1 do
      post inquiries_path, params: { inquiry: valid_attributes }
    end

    assert_response :created
    inquiry = Inquiry.order(:created_at).last
    expected = PackagingEstimator.call(**inquiry.calculator_attributes)
    assert_nil inquiry.supplier
    assert_equal expected.unit_price, inquiry.estimated_unit_price
    assert_equal expected.total_price, inquiry.estimated_total_price
    assert_equal expected.low_price, inquiry.estimated_low_price
    assert_equal expected.high_price, inquiry.estimated_high_price
    assert_select ".inquiry-confirmation", /учебная заявка не отправлена компании/i
  end

  test "creates an inquiry for an active supplier" do
    post inquiries_path, params: {
      inquiry: valid_attributes.merge(supplier_id: suppliers(:kraft_factory).id)
    }

    assert_response :created
    assert_equal suppliers(:kraft_factory), Inquiry.order(:created_at).last.supplier
  end

  test "rejects invalid email and fields without persistence" do
    assert_no_difference -> { Inquiry.count } do
      post inquiries_path, params: {
        inquiry: valid_attributes.merge(email: "wrong", length_mm: 0, quantity: -1)
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors", /Email|Длина|Тираж/i
  end

  test "rejects an unknown material" do
    assert_no_difference -> { Inquiry.count } do
      post inquiries_path, params: {
        inquiry: valid_attributes.merge(material_slug: "invented-material")
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors", /материал/i
  end

  test "rejects inactive and forged supplier ids" do
    [ suppliers(:inactive_studio).id, 999_999 ].each do |supplier_id|
      assert_no_difference -> { Inquiry.count } do
        post inquiries_path, params: {
          inquiry: valid_attributes.merge(supplier_id: supplier_id)
        }
      end

      assert_response :unprocessable_entity
      assert_select ".form-errors", /поставщик/i
    end
  end

  test "ignores client supplied estimate values" do
    post inquiries_path, params: {
      inquiry: valid_attributes.merge(
        estimated_unit_price: 1,
        estimated_total_price: 1,
        estimated_low_price: 1,
        estimated_high_price: 1
      )
    }

    assert_response :created
    inquiry = Inquiry.order(:created_at).last
    assert_equal 24.to_d, inquiry.estimated_unit_price
    assert_equal 12_000.to_d, inquiry.estimated_total_price
  end

  private

  def valid_attributes
    {
      email: "Owner@Example.test ",
      product_type: "Свечи в стекле",
      length_mm: 90,
      width_mm: 90,
      height_mm: 110,
      weight_grams: 0,
      fragile: false,
      material_slug: "microcorrugated-cardboard",
      quantity: 500,
      budget: 15_000,
      deadline: Date.current + 30.days,
      region: "Москва",
      print_option: "none",
      extras: []
    }
  end
end
