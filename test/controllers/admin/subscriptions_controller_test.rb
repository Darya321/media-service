require "test_helper"

class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get admin_subscriptions_path
    assert_redirected_to new_admin_session_path
  end

  test "lists subscriptions without mutation controls" do
    post admin_session_path, params: { session: { email: admins(:owner).email, password: "correct-horse-battery" } }
    get admin_subscriptions_path

    assert_response :success
    assert_select "h1", "Подписки"
    assert_includes response.body, subscriptions(:reader).email
    assert_select "form[action*='/admin/subscriptions']", count: 0
  end
end
