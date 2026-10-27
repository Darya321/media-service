require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "home media covers follow the publication category" do
    post = posts(:published_article)

    post.category = categories(:materials)
    assert_equal "editorial/media-material-guide-v2.png", home_media_asset(post)

    post.category = categories(:suppliers)
    assert_equal "editorial/media-maker-story-v2.png", home_media_asset(post)

    post.category = categories(:business_cases)
    assert_equal "editorial/media-cardboard-review-v2.png", home_media_asset(post)
  end

  test "home media covers use the material guide for an unmapped category" do
    post = posts(:published_without_date)

    assert_equal "editorial/media-material-guide-v2.png", home_media_asset(post)
  end
end
