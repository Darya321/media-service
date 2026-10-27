require "test_helper"

class CalculatorControllerTest < ActionDispatch::IntegrationTest
  test "shows the calculator with available materials" do
    get calculator_path

    assert_response :success
    assert_select "h1", /Узнайте, сколько стоит упаковка/
    assert_select "input[value='microcorrugated-cardboard']"
  end

  test "returns the reference estimate as json without persisting a lead" do
    assert_no_difference -> { Inquiry.count } do
      post estimate_calculator_path, params: reference_params, as: :json
    end

    assert_response :success
    payload = response.parsed_body
    assert_equal 24.0, payload.fetch("unit_price")
    assert_equal 12_000.0, payload.fetch("total_price")
    assert_equal 21.12, payload.fetch("low_price")
    assert_equal 28.08, payload.fetch("high_price")
    assert_equal %w[assembly delivery material printing waste], payload.fetch("breakdown").keys.sort
    assert_match(/предваритель/i, payload.fetch("disclaimer"))
  end

  test "returns validation errors with 422" do
    post estimate_calculator_path,
      params: reference_params.merge(length_mm: "wrong", quantity: 0),
      as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.fetch("errors").keys, "length_mm"
    assert_includes response.parsed_body.fetch("errors").keys, "quantity"
  end

  test "returns 422 for an unknown material" do
    post estimate_calculator_path,
      params: reference_params.merge(material_slug: "invented-material"),
      as: :json

    assert_response :unprocessable_entity
    assert_equal [ "Выберите материал из списка" ], response.parsed_body.dig("errors", "material")
  end

  test "ignores a client supplied material factor and price" do
    post estimate_calculator_path,
      params: reference_params.merge(price_factor: 0.01, unit_price: 1),
      as: :json

    assert_response :success
    assert_equal 24.0, response.parsed_body.fetch("unit_price")
  end

  private

  def reference_params
    {
      product_type: "Свечи в стекле",
      length_mm: 90,
      width_mm: 90,
      height_mm: 110,
      weight_grams: 0,
      fragile: false,
      material_slug: "microcorrugated-cardboard",
      quantity: 500,
      region: "Москва",
      print_option: "none",
      extras: []
    }
  end
end
