require "application_system_test_case"

class PublicJourneyTest < ApplicationSystemTestCase
  test "visitor moves from editorial guidance to calculation supplier and demo inquiry" do
    visit posts_path
    click_link "Как выбрать картон"
    assert_text "Основной текст опубликованной статьи"

    click_link "Сравнить материалы"
    click_link "Микрогофрокартон"
    assert_text "4 из 5"
    click_link "Рассчитать с этим материалом"

    click_button "Рассчитать"
    assert_text "24 ₽"
    assert_text "Расчёт предварительный"
    click_link "Показать подходящие компании"

    assert_text "Крафт упаковка"
    within "[data-supplier-slug='kraft-packaging']" do
      click_link "Подробнее"
    end
    click_link "Оставить заявку"

    assert_text "Она не будет отправлена выбранной компании"
    fill_in "Email", with: "journey@example.test"
    click_button "Создать учебную заявку"

    assert_text "Параметры заявки сохранены"
    assert_text "не отправлена компании"
    assert_text "24 ₽"
  end
end
