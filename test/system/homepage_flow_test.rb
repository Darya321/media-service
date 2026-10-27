require "application_system_test_case"

class HomepageFlowTest < ApplicationSystemTestCase
  test "homepage exposes the full bleed wordmark and typography treatment" do
    visit root_path

    assert_selector "body[data-controller~='typography']"
    assert_selector ".hero-shell__wordmark[data-full-bleed-wordmark]", text: "Упаковано"
  end

  test "homepage connects its tools content and local subscription" do
    visit root_path

    assert_text "Упаковка, которая работает на бизнес"
    assert_link "Все материалы", href: materials_path
    assert_link "Все поставщики", href: suppliers_path
    assert_link "Все публикации", href: posts_path

    within "#home-calculator" do
      click_button "Рассчитать стоимость"
    end

    assert_current_path calculator_path, ignore_query: true
    assert_text "24 ₽"

    visit root_path
    within "#subscription" do
      fill_in "Email для материалов", with: "home@example.test"
      click_button "Подписаться"
    end
    assert_current_path root_path
    assert_text "Подписка сохранена"
  end

  test "repeat order exposes fixed demo values to the Stimulus controller" do
    visit root_path

    assert_selector "[data-controller~='repeat-order']"
    assert_button "Повторить демо-заказ"
    assert_selector "[data-repeat-order-target='quantity'][value='500']"
    assert_text(/фиксированн.*демо/i)
  end
end
