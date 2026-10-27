require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "valid email creates a local subscription without mail delivery" do
    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      assert_difference -> { Subscription.count }, 1 do
        post subscriptions_path, params: { subscription: { email: " NewReader@Example.test " } }
      end
    end

    assert_redirected_to root_path(anchor: "subscription")
    assert_equal "newreader@example.test", Subscription.order(:created_at).last.email
  end

  test "invalid email redirects with feedback and does not persist" do
    assert_no_difference -> { Subscription.count } do
      post subscriptions_path, params: { subscription: { email: "wrong" } }
    end

    assert_redirected_to root_path(anchor: "subscription")
    assert_match(/email/i, flash[:alert])
  end

  test "case and whitespace duplicate is rejected" do
    assert_no_difference -> { Subscription.count } do
      post subscriptions_path, params: { subscription: { email: " READER@EXAMPLE.TEST " } }
    end

    assert_redirected_to root_path(anchor: "subscription")
    assert_match(/уже/i, flash[:alert])
  end

  test "turbo request replaces the subscription form" do
    post subscriptions_path,
      params: { subscription: { email: "turbo@example.test" } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_includes response.body, 'target="subscription-form"'
    assert_includes response.body, "Подписка сохранена"
  end
end
