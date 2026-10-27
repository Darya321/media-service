require "test_helper"

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @studio = Supplier.create!(
      name: "Студия формы",
      slug: "form-studio",
      company_type: :design_studio,
      specialization: "Дизайн упаковки",
      description: "Разрабатывает конструкцию и графику.",
      minimum_order: 1,
      unit_price_from: 8,
      regions: [ "Санкт-Петербург" ],
      services: [ "Дизайн" ],
      active: true
    )
    @studio.materials << materials(:craft_cardboard)
  end

  test "index lists only available suppliers and labels promoted entries" do
    get suppliers_path

    assert_response :success
    assert_select "[data-supplier-slug='kraft-packaging']", /Крафт упаковка/
    assert_select "[data-supplier-slug='kraft-packaging']", /Реклама/
    assert_select "[data-supplier-slug='archived-studio']", count: 0
  end

  test "filters by company type material and region" do
    get suppliers_path, params: {
      company_type: "design_studio",
      material: "craft-cardboard",
      region: "Санкт-Петербург"
    }

    assert_response :success
    assert_select "[data-supplier-slug='form-studio']", count: 1
    assert_select "[data-supplier-slug='kraft-packaging']", count: 0
  end

  test "filters by material without duplicate rows" do
    get suppliers_path, params: { material: "microcorrugated-cardboard" }

    assert_response :success
    assert_select "[data-supplier-slug='kraft-packaging']", count: 1
    assert_select "[data-supplier-slug='form-studio']", count: 0
  end

  test "shows a supplier card by slug" do
    get supplier_path(suppliers(:kraft_factory))

    assert_response :success
    assert_select "h1", "Крафт упаковка"
    assert_select "a", text: /Оставить заявку/
  end

  test "inactive and unknown suppliers return not found" do
    get supplier_path(suppliers(:inactive_studio))
    assert_response :not_found

    get supplier_path("missing-supplier")
    assert_response :not_found
  end

  test "empty filters render a useful empty state" do
    get suppliers_path, params: { region: "Регион без поставщиков" }

    assert_response :success
    assert_select ".empty-state", /не нашли/i
  end
end
