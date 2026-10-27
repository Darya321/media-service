require "application_system_test_case"

class SupplierInquiryFlowTest < ApplicationSystemTestCase
  test "moves from supplier list to detail and educational inquiry confirmation" do
    visit suppliers_path

    within "[data-supplier-slug='kraft-packaging']" do
      click_link "Подробнее"
    end

    assert_text "Крафт упаковка"
    click_link "Оставить заявку"

    fill_in "Email", with: "owner@example.test"
    click_button "Создать учебную заявку"

    assert_current_path inquiries_path
    assert_text(/учебная заявка не отправлена компании/i)
    assert_text "24 ₽"
    assert_text "Крафт упаковка"
  end
end
