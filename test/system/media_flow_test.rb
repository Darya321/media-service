require "application_system_test_case"

class MediaFlowTest < ApplicationSystemTestCase
  test "searches and filters media before opening a useful publication" do
    visit posts_path

    within ".media-toolbar" do
      fill_in "Поиск по медиа", with: "картон"
      click_button "Найти"
    end
    assert_current_path posts_path(q: "картон")
    assert_selector ".media-results"

    within ".media-categories" do
      click_link "Материалы"
    end
    assert_current_path posts_path(q: "картон", category: "materials")

    click_link "Как выбрать картон"
    assert_current_path post_path("how-to-choose-cardboard")
    assert_text "Основной текст опубликованной статьи"
    assert_link "Сравнить материалы", href: materials_path
    assert_link "Рассчитать упаковку", href: calculator_path
  end

  test "distinguishes partner and external placements" do
    visit posts_path

    within "[data-post-slug='partner-box-line']" do
      assert_text "Партнёрский материал"
      click_link "Новая линия коробок"
    end

    assert_link "О компании", href: supplier_path(suppliers(:kraft_factory))

    visit posts_path
    within ".media-promotion" do
      assert_text "Внешний сайт"
      assert_link "Смотреть предложение", href: "https://partner.example/offers"
    end
  end
end
