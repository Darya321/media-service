require "test_helper"

class Admin::SessionsControllerTest < ActionController::TestCase
  tests Admin::SessionsController

  test "signs in with a normalized email and resets the previous session" do
    session[:pre_login_marker] = "must disappear"

    post :create, params: {
      session: { email: " OWNER@EXAMPLE.TEST ", password: "correct-horse-battery" }
    }

    assert_redirected_to admin_root_path
    assert_equal admins(:owner).id, session[:admin_id]
    assert_nil session[:pre_login_marker]
  end

  test "rejects invalid credentials with a generic message" do
    post :create, params: {
      session: { email: admins(:owner).email, password: "definitely-wrong" }
    }

    assert_response :unprocessable_entity
    assert_nil session[:admin_id]
    assert_includes response.body, "Не удалось войти"
    refute_includes response.body, admins(:owner).email
  end

  test "signs out and clears the session" do
    session[:admin_id] = admins(:owner).id
    session[:pre_logout_marker] = "must disappear"

    delete :destroy

    assert_redirected_to new_admin_session_path
    assert_nil session[:admin_id]
    assert_nil session[:pre_logout_marker]
  end
end
