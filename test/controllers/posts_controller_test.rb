require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "index shows published posts with featured first and hides non-public posts" do
    get posts_path

    assert_response :success
    assert_select ".post-card", minimum: 2
    assert_select ".post-card:first-child h2", /Как выбрать картон/
    assert_select "[data-post-slug='draft-review']", count: 0
    assert_select "[data-post-slug='future-news']", count: 0
  end

  test "index filters by category slug" do
    get posts_path, params: { category: "materials" }

    assert_response :success
    assert_select "[data-post-slug='how-to-choose-cardboard']", count: 1
    assert_select "[data-post-slug='print-layout']", count: 0
  end

  test "show renders a public post by slug with escaped body" do
    post = posts(:published_article)
    post.update!(body: "Первый абзац.\n\n<script>alert('x')</script>")

    get post_path(post)

    assert_response :success
    assert_select "h1", post.title
    assert_select "article script", count: 0
    assert_includes response.body, "&lt;script&gt;"
  end

  test "draft future and unknown post urls return not found" do
    [ posts(:draft_article).slug, posts(:future_article).slug, "missing-post" ].each do |slug|
      get post_path(slug)
      assert_response :not_found
    end
  end
end
