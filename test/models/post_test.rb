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
end
