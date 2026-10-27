require "application_system_test_case"

class CalculatorFlowTest < ApplicationSystemTestCase
  test "calculates the reference package and offers the next steps" do
    visit calculator_path

    choose "Свечи"
    fill_in "Длина, мм", with: "90"
    fill_in "Ширина, мм", with: "90"
    fill_in "Высота, мм", with: "110"
    fill_in "Вес, г", with: "0"
    choose "Нехрупкий"
    choose "Микрогофрокартон"
    choose "Без печати"
    fill_in "Тираж, шт", with: "500"
    select "Москва", from: "Регион доставки"

    click_button "Рассчитать"

    assert_current_path estimate_calculator_path
    assert_selector "[data-calculator-target='unitPrice']", text: "24 ₽"
    assert_text "12 000 ₽ за 500 штук"
    assert_text "21–28 ₽"
    assert_text(/предваритель/i)
    assert_link "Показать подходящие компании", href: suppliers_path(material: "microcorrugated-cardboard", region: "Москва")
    assert_link "Оставить заявку", href: new_inquiry_path
  end
end
