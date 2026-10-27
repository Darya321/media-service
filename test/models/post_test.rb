require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires editorial content and a category" do
    post = Post.new

    refute post.valid?
    %i[title summary body category].each do |attribute|
      assert post.errors[attribute].any?, "expected #{attribute} to be required"
    end
  end

  test "supports every approved publication kind and state" do
    assert_equal %w[article guide review interview news], Post.kinds.keys
    assert_equal %w[draft published], Post.statuses.keys
    assert_equal %w[editorial partner external], Post.placements.keys
  end

  test "editorial post does not require a supplier" do
    post = build_post(placement: :editorial)

    assert post.valid?
    assert_nil post.supplier
  end

  test "partner post requires a supplier" do
    post = build_post(placement: :partner)

    refute post.valid?
    assert post.errors[:supplier].any?

    post.supplier = suppliers(:kraft_factory)

    assert post.valid?
  end

  test "partner post requires an active supplier" do
    post = build_post(placement: :partner, supplier: suppliers(:inactive_studio))

    refute post.valid?
    assert post.errors[:supplier].any?
  end

  test "external placement requires a safe absolute web url" do
    post = build_post(placement: :external)

    refute post.valid?
    assert post.errors[:external_url].any?

    post.external_url = "javascript:alert('unsafe')"

    refute post.valid?
    assert post.errors[:external_url].any?

    post.external_url = "https://partner.example/offers"

    assert post.valid?
  end

  test "promotable excludes a partner post whose supplier was removed" do
    post = build_post(placement: :partner, supplier: suppliers(:kraft_factory))
    post.save!
    post.update_column(:supplier_id, nil)

    refute_includes Post.promotable, post
  end

  test "search finds title summary and body without case sensitivity" do
    assert_includes Post.search_for("КАК ВЫБРАТЬ"), posts(:published_article)
    assert_includes Post.search_for("КОРОТКИЙ ОРИЕНТИР"), posts(:published_article)
    assert_includes Post.search_for("ОСНОВНОЙ ТЕКСТ ИНСТРУКЦИИ"), posts(:published_without_date)
  end

  test "blank search stays chainable and returns every post" do
    result = Post.search_for("   ")

    assert_kind_of ActiveRecord::Relation, result
    assert_equal Post.order(:id).pluck(:id), result.order(:id).pluck(:id)
  end

  test "search treats percent and underscore as literal characters" do
    percent_match = build_post(title: "Скидка 100%", slug: "literal-percent")
    percent_decoy = build_post(title: "Скидка 1000", slug: "percent-decoy")
    underscore_match = build_post(title: "Серия A_B", slug: "literal-underscore")
    underscore_decoy = build_post(title: "Серия AXB", slug: "underscore-decoy")
    [ percent_match, percent_decoy, underscore_match, underscore_decoy ].each(&:save!)

    assert_equal [ percent_match ], Post.search_for("100%").to_a
    assert_equal [ underscore_match ], Post.search_for("A_B").to_a
  end

  test "generates a stable slug from its title" do
    post = Post.new(
      category: categories(:materials),
      title: "Cardboard Printing Guide",
      summary: "Summary",
      body: "Body",
      kind: :guide,
      status: :draft
    )

    assert post.valid?
    assert_equal "cardboard-printing-guide", post.slug
    assert_equal "cardboard-printing-guide", post.to_param

    post.title = "Updated title"
    post.validate

    assert_equal "cardboard-printing-guide", post.slug
  end

  test "publicly visible returns published current content only" do
    visible = Post.publicly_visible

    assert_includes visible, posts(:published_article)
    assert_includes visible, posts(:published_without_date)
    refute_includes visible, posts(:draft_article)
    refute_includes visible, posts(:future_article)
  end

  private

  def build_post(**attributes)
    Post.new({
      category: categories(:materials),
      title: "Новый материал",
      slug: "new-media-post-#{SecureRandom.hex(4)}",
      summary: "Краткое описание.",
      body: "Основной текст.",
      kind: :article,
      status: :draft
    }.merge(attributes))
  end
end
