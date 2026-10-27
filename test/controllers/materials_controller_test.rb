require "test_helper"

class MaterialsControllerTest < ActionDispatch::IntegrationTest
  test "index lists materials and exposes all score values as text" do
    get materials_path

    assert_response :success
    assert_select "[data-material-slug='microcorrugated-cardboard']", count: 1
    assert_select "[data-material-slug='craft-cardboard']", count: 1
    assert_select "[data-material-slug='microcorrugated-cardboard'] .material-score", count: 4
    assert_select "[data-material-slug='microcorrugated-cardboard'] .material-score__value", text: /4 из 5/, count: 3
    assert_select "[data-material-slug='microcorrugated-cardboard'] .material-score__value", text: /3 из 5/, count: 1
  end

  test "use case filter is case insensitive" do
    get materials_path, params: { use_case: "ПОСУДА" }

    assert_response :success
    assert_select "[data-material-slug='microcorrugated-cardboard']", count: 1
    assert_select "[data-material-slug='craft-cardboard']", count: 0
  end

  test "empty use case results render an explanation" do
    get materials_path, params: { use_case: "космический корабль" }

    assert_response :success
    assert_select ".empty-state", /не нашли/i
  end

  test "show renders scores suppliers disclaimer and next steps" do
    get material_path(materials(:microcorrugated))

    assert_response :success
    assert_select "h1", "Микрогофрокартон"
    assert_select ".material-score", count: 4
    assert_select ".material-detail__suppliers", /Крафт упаковка/
    assert_select ".material-disclaimer", /ориентир/i
    assert_select "a[href='#{calculator_path(material_slug: "microcorrugated-cardboard")}']"
    assert_select "a[href='#{suppliers_path(material: "microcorrugated-cardboard")}']"
  end

  test "unknown slug returns not found" do
    get material_path("missing-material")

    assert_response :not_found
  end
end
