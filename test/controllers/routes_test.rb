require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  test "exposes the approved public route contract" do
    assert_equal "/", root_path
    assert_equal "/about", about_path
    assert_equal "/media", posts_path
    assert_equal "/media/example-post", post_path("example-post")
    assert_equal "/categories/materials", category_path("materials")
    assert_equal "/materials", materials_path
    assert_equal "/materials/cardboard", material_path("cardboard")
    assert_equal "/calculator", calculator_path
    assert_equal "/calculator/estimate", estimate_calculator_path
    assert_equal "/suppliers", suppliers_path
    assert_equal "/suppliers/factory", supplier_path("factory")
    assert_equal "/subscriptions", subscriptions_path
    assert_equal "/inquiries/new", new_inquiry_path
    assert_equal "/inquiries", inquiries_path
  end

  test "exposes the protected admin route contract" do
    assert_equal "/admin", admin_root_path
    assert_equal "/admin/session/new", new_admin_session_path
    assert_equal "/admin/session", admin_session_path
    assert_equal "/admin/categories", admin_categories_path
    assert_equal "/admin/posts", admin_posts_path
    assert_equal "/admin/materials", admin_materials_path
    assert_equal "/admin/suppliers", admin_suppliers_path
    assert_equal "/admin/subscriptions", admin_subscriptions_path
    assert_equal "/admin/inquiries", admin_inquiries_path
  end
end
