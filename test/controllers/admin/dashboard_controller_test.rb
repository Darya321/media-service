require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects an unauthenticated visitor to the admin login" do
    get admin_root_path

    assert_redirected_to new_admin_session_path
  end

  test "shows dashboard counters to an authenticated admin" do
    post admin_session_path, params: {
      session: { email: admins(:owner).email, password: "correct-horse-battery" }
    }
    get admin_root_path

    assert_response :success
    assert_select "h1", "Панель управления"
    assert_select "[data-admin-count='posts']", text: Post.count.to_s
    assert_select "[data-admin-count='materials']", text: Material.count.to_s
    assert_select "[data-admin-count='suppliers']", text: Supplier.count.to_s
    assert_select "[data-admin-count='inquiries']", text: Inquiry.count.to_s
  end
end
