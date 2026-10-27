require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "category page shows its description and only public posts" do
    get category_path(categories(:materials))

    assert_response :success
    assert_select "h1", "Материалы"
    assert_includes response.body, categories(:materials).description
    assert_select "[data-post-slug='how-to-choose-cardboard']", count: 1
    assert_select "[data-post-slug='draft-review']", count: 0
    assert_select "[data-post-slug='future-news']", count: 0
  end

  test "unknown category returns not found" do
    get category_path("missing-category")

    assert_response :not_found
  end
end
