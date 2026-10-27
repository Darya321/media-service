require "application_system_test_case"

class MediaFlowTest < ApplicationSystemTestCase
  test "moves from media through category and publication to useful next steps" do
    visit posts_path

    within ".media-categories" do
      click_link "Материалы"
    end
    assert_current_path category_path("materials")

    click_link "Как выбрать картон"
    assert_current_path post_path("how-to-choose-cardboard")
    assert_text "Основной текст опубликованной статьи"
    assert_link "Сравнить материалы", href: materials_path
    assert_link "Рассчитать упаковку", href: calculator_path
  end
end
