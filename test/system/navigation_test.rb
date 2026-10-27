require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "desktop navigation opens the about page and returns home" do
    visit root_path

    assert_selector ".site-header .brand[href='#{root_path}'][aria-label='Упаковано — на главную']" do
      assert_selector "img.brand__logo[src*='upakovano-wordmark'][alt='']", count: 1
    end
    assert_link "О проекте", href: about_path

    within(".site-header") { click_link "О проекте" }

    assert_current_path about_path
    assert_selector ".about-hero h1", text: "Упаковано"
    assert_selector ".about-capabilities [data-capability]", count: 4
    assert_selector "#manufacturers[data-audience='manufacturers']"

    within(".site-header") { find("a.brand[href='#{root_path}']").click }

    assert_current_path root_path
  end

  test "mobile navigation exposes accessible Stimulus wiring" do
    visit root_path

    button = find("button[aria-controls='site-navigation']")
    assert_equal "false", button["aria-expanded"]
    assert_includes button["data-action"], "click->menu#toggle"
    assert_includes button["data-action"], "keydown.esc@window->menu#close"
    assert_selector "#site-navigation[data-menu-target='panel']", visible: :all
  end
end
