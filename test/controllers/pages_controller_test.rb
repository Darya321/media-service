require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about explains the educational service and its limitations" do
    get about_path

    assert_response :success
    assert_select "h1", "О проекте"
    assert_select ".about-principles", /предваритель/i
    assert_select ".about-principles", /учебн/i
    assert_select "a[href='#{calculator_path}']", "Перейти к расчёту"
  end
end
