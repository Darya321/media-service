require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "holding page presents the brand without replacing the homepage" do
    get "/soon"

    assert_response :success
    assert_select "body.holding-page"
    assert_select "header.site-header", count: 0
    assert_select ".holding-brand img[src*='upakovano-wordmark']", count: 1
    assert_select "h1", /Скоро здесь будет/
    assert_select "img[src*='hero-packaging-island'][alt='']", count: 1
    assert_select "a[href='#{root_path}']", text: /Открыть проект/
  end

  test "public layout exposes the supplied leaf as its browser icon" do
    get root_path

    assert_response :success
    assert_select "link[rel='icon'][href*='upakovano-leaf'][type='image/png']", count: 1
    assert_select "link[rel='apple-touch-icon'][href*='upakovano-leaf']", count: 1
  end

  test "about explains the educational service and its limitations" do
    get about_path

    assert_response :success
    assert_select "article.about-page"
    assert_select ".about-hero h1", /Упаковано/
    assert_select ".about-capabilities [data-capability]", count: 4
    assert_select ".about-audiences [data-audience]", count: 2
    assert_select ".about-audiences #manufacturers[data-audience='manufacturers']", count: 1
    assert_select ".about-principles", /предваритель/i
    assert_select ".about-principles", /учебн/i
    assert_select "a[href='#{calculator_path}']", "Перейти к расчёту"
    assert_select "a[href='#{posts_path}']", "Читать материалы"
  end
end
