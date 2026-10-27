require "application_system_test_case"

class ResponsiveLayoutTest < ApplicationSystemTestCase
  test "public navigation and supplier comparison expose responsive hooks" do
    visit root_path

    assert_link "Рассчитать", href: calculator_path
    assert_selector ".menu-button[aria-controls='site-navigation']"
    assert_selector ".site-nav[data-menu-target='panel']", visible: :all

    visit suppliers_path
    assert_selector ".supplier-table[role='table'][data-responsive-layout='table-to-cards']"
    assert_selector ".supplier-row [data-label='Специализация']", minimum: 1
    assert_selector ".supplier-row [data-label='Мин. тираж']", minimum: 1
    assert_selector ".supplier-row [data-label='Материалы']", minimum: 1
    assert_selector ".supplier-row [data-label='Цена от']", minimum: 1
  end

  test "responsive stylesheet covers compact layouts and reduced motion" do
    css = Rails.root.join("app/assets/stylesheets/responsive.css").read

    assert_includes css, "@media (max-width: 900px)"
    assert_includes css, "@media (max-width: 560px)"
    assert_includes css, ".supplier-table__body"
    assert_includes css, "@media (prefers-reduced-motion: reduce)"
    assert_includes css, "scroll-behavior: auto"
  end

  test "media stylesheet defines tablet and phone compositions" do
    css = Rails.root.join("app/assets/stylesheets/responsive.css").read
    tablet_rules = css[/@media \(max-width: 900px\).*?(?=@media \(max-width: 560px\))/m]
    phone_rules = css[/@media \(max-width: 560px\).*?(?=@media \(prefers-reduced-motion)/m]

    %w[.media-hero .media-toolbar .media-section__grid .media-promotion].each do |selector|
      assert_includes tablet_rules, selector
      assert_includes phone_rules, selector
    end
  end
end
