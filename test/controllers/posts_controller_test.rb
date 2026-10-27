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

  test "index selects a featured hero and prepares editorial sections" do
    get posts_path

    assert_response :success
    assert_equal posts(:published_article), assigned(:hero_post)
    assert_equal %w[materials suppliers business-cases legislation], assigned(:media_categories).map(&:slug)
    assert_includes assigned(:supplier_posts), posts(:partner_article)
    assert_equal posts(:external_placement), assigned(:business_feature)
    assert_includes assigned(:legislation_posts), posts(:legislation_news)
    assert_instance_of Subscription, assigned(:subscription)
  end

  test "index combines search and category filters" do
    get posts_path, params: { q: "ПРОИЗВОДСТВЕ НЕБОЛЬШИХ", category: "suppliers" }

    assert_response :success
    assert assigned(:filtering)
    assert_equal "ПРОИЗВОДСТВЕ НЕБОЛЬШИХ", assigned(:query)
    assert_equal categories(:suppliers), assigned(:selected_category)
    assert_equal [ posts(:partner_article) ], assigned(:posts).to_a
  end

  test "unknown category produces an empty result instead of all posts" do
    get posts_path, params: { category: "missing-topic" }

    assert_response :success
    assert assigned(:filtering)
    assert_nil assigned(:selected_category)
    assert_empty assigned(:posts)
  end

  test "editorial sections exclude draft and future posts" do
    hidden_supplier = Post.create!(
      category: categories(:suppliers), title: "Скрытая новость", slug: "hidden-supplier-news",
      summary: "Черновик.", body: "Не показывать.", kind: :news, status: :draft
    )
    future_law = Post.create!(
      category: categories(:legislation), title: "Будущее требование", slug: "future-law",
      summary: "Ещё рано.", body: "Не показывать.", kind: :news, status: :published,
      published_at: 2.days.from_now
    )

    get posts_path

    refute_includes assigned(:supplier_posts), hidden_supplier
    refute_includes assigned(:legislation_posts), future_law
    refute_equal hidden_supplier, assigned(:hero_post)
    refute_equal future_law, assigned(:hero_post)
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

  private

  def assigned(name)
    response.request.controller_instance.instance_variable_get(:"@#{name}")
  end
end
