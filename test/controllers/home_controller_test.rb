require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "homepage uses public database content and excludes hidden rows" do
    get root_path

    assert_response :success
    assert_select "[data-home-material='microcorrugated-cardboard']", count: 1
    assert_select "[data-home-supplier='kraft-packaging']", count: 1
    assert_select "[data-home-supplier='archived-studio']", count: 0
    assert_select "[data-home-post='how-to-choose-cardboard']", count: 1
    assert_select "[data-home-post='draft-review']", count: 0
    assert_select "[data-home-post='future-news']", count: 0
  end

  test "homepage sections follow the approved Figma order" do
    get root_path

    ids = %w[hero tools steps home-calculator suppliers media repeat-order manufacturers subscription]
    positions = ids.map { |id| response.body.index("id=\"#{id}\"") }
    assert positions.all?, "expected every homepage section"
    assert_equal positions.sort, positions
  end

  test "short calculator carries the exact reference inputs" do
    get root_path

    assert_select "form[action='#{calculator_path}'][method='get']" do
      assert_select "input[name='product_type'][value='Свечи в стекле']"
      assert_select "input[name='length_mm'][value='90']"
      assert_select "input[name='width_mm'][value='90']"
      assert_select "input[name='height_mm'][value='110']"
      assert_select "input[name='quantity'][value='500']"
      assert_select "select[name='material_slug'] option[value='microcorrugated-cardboard'][selected]"
      assert_select "select[name='region'] option[value='Москва'][selected]"
    end
    assert_select "[data-home-reference-price]", text: /24 ₽/ do
      assert_select ".price-chart[role='img'] .price-chart__bar", count: 5
      assert_select ".price-chart__bar.is-active[data-quantity='500']", count: 1
      assert_select ".home-calculator__meta dd", text: "Микрогофрокартон", count: 1
      assert_select ".home-calculator__meta dd", text: "Москва", count: 1
      assert_select ".home-calculator__disclaimer", text: /Предварительный расчет/
    end
  end

  test "homepage hero layers the identity wordmark behind a native-size island" do
    get root_path

    assert_response :success
    assert_select ".hero-shell__stage" do
      assert_select ".identity-wordmark[data-full-bleed-wordmark]", text: "Упаковано"
      assert_select "img.hero-shell__art[width='546'][height='331']", count: 1
      assert_select ".hero-shell__copy h1", text: /работает на бизнес/
    end

    wordmark_position = response.body.index("identity-wordmark")
    island_position = response.body.index("hero-shell__art")
    assert_operator wordmark_position, :<, island_position
  end
end
