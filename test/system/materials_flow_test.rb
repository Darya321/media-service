require "application_system_test_case"

class MaterialsFlowTest < ApplicationSystemTestCase
  test "filters the catalogue opens a material and offers useful next steps" do
    visit materials_path(use_case: "посуда")

    assert_text "Микрогофрокартон"
    refute_text "Крафт-картон"
    click_link "Микрогофрокартон"

    assert_current_path material_path("microcorrugated-cardboard")
    assert_text "4 из 5"
    assert_link "Рассчитать с этим материалом", href: calculator_path(material_slug: "microcorrugated-cardboard")
    assert_link "Найти поставщиков", href: suppliers_path(material: "microcorrugated-cardboard")
  end
end
