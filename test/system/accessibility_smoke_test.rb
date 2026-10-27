require "application_system_test_case"

class AccessibilitySmokeTest < ApplicationSystemTestCase
  test "pages have a single heading skip link and described images" do
    [ root_path, calculator_path, materials_path, suppliers_path, new_inquiry_path ].each do |path|
      visit path
      assert_selector "h1", count: 1
      assert_link "Перейти к содержанию", href: "#main-content", visible: :all
      all("img", visible: :all).each { |image| assert_not_nil image[:alt], "#{path} image must have alt" }
    end
  end

  test "calculator groups choices labels controls and announces results" do
    visit calculator_path

    assert_selector "[role='group'][aria-labelledby='product-type-label']"
    assert_selector "[role='group'][aria-labelledby='material-label']"
    assert_selector "label[for='length_mm']", text: "Длина, мм"
    assert_selector "label[for='quantity']", text: "Тираж, шт"
    assert_selector ".calculator-result[role='status'][aria-live='polite']"
  end

  test "menu supports keyboard closing and scores include text values" do
    visit root_path

    menu_button = find(".menu-button", visible: :all)
    assert_includes menu_button["data-action"], "keydown.esc@window->menu#close"

    visit materials_path
    assert_selector ".material-score[aria-label*='из 5']", minimum: 1
    assert_selector ".material-score__value", text: /\d из 5/, minimum: 1

    css = Rails.root.join("app/assets/stylesheets/application.css").read
    assert_includes css, ":focus-visible"
  end
end
