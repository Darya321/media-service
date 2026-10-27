require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about explains the educational service and its limitations" do
    get about_path

    assert_response :success
    assert_select "article.about-page"
    assert_select ".about-hero h1", /Упаковано/
    assert_select ".about-capabilities [data-capability]", count: 4
    assert_select ".about-audiences [data-audience]", count: 2
    assert_select ".about-audiences #manufacturers[data-audience='manufacturers']", count: 1
    assert_select ".about-principles", /предваритель/i
    assert_select ".about-principles", /учебн/i
    assert_select "a[href='#{calculator_path}']", "Перейти к расчёту"
    assert_select "a[href='#{posts_path}']", "Читать материалы"
  end
end
