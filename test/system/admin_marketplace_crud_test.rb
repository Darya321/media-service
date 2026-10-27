require "application_system_test_case"

class AdminMarketplaceCrudTest < ApplicationSystemTestCase
  test "editor creates public catalogue records, deactivates supplier, and reviews a lead" do
    visit new_admin_session_path
    fill_in "Email", with: admins(:owner).email
    fill_in "Пароль", with: "correct-horse-battery"
    click_button "Войти"

    click_link "Материалы"
    click_link "Добавить материал"
    fill_in "Название", with: "Глассин"
    fill_in "Адрес страницы", with: "glassine-paper"
    fill_in "Краткое описание", with: "Тонкая полупрозрачная бумага."
    fill_in "Подробное описание", with: "Подходит для внутренней упаковки."
    fill_in "Применение", with: "Косметика, выпечка"
    fill_in "Прочность", with: 2
    fill_in "Печать", with: 3
    fill_in "Экологичность", with: 4
    fill_in "Доступность цены", with: 4
    fill_in "Коэффициент цены", with: 0.8
    click_button "Создать материал"
    assert_text "Глассин"

    click_link "Поставщики"
    click_link "Добавить поставщика"
    fill_in "Название", with: "Бумажная лаборатория"
    fill_in "Адрес страницы", with: "paper-lab"
    select "Фабрика", from: "Тип компании"
    fill_in "Специализация", with: "Малая фабрика"
    fill_in "Описание", with: "Производит небольшие партии упаковки."
    fill_in "Минимальный тираж", with: 100
    fill_in "Цена от", with: 12.5
    fill_in "Регионы", with: "Москва, Казань"
    fill_in "Услуги", with: "Печать, Вырубка"
    check "Глассин"
    check "Активен"
    click_button "Создать поставщика"
    assert_text "Бумажная лаборатория"

    visit supplier_path(Supplier.find_by!(slug: "paper-lab"))
    assert_text "Бумажная лаборатория"

    visit edit_admin_supplier_path(Supplier.find_by!(slug: "paper-lab"))
    uncheck "Активен"
    click_button "Сохранить поставщика"
    visit suppliers_path
    assert_no_text "Бумажная лаборатория"

    visit admin_inquiry_path(inquiries(:candle_boxes))
    select "На рассмотрении", from: "Статус заявки"
    click_button "Сохранить статус"
    assert_text "Статус заявки обновлён"
    assert_text "На рассмотрении"
  end
end
