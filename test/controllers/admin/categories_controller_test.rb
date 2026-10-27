require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "requires authentication" do
    delete admin_session_path
    get admin_categories_path

    assert_redirected_to new_admin_session_path
  end

  test "renders every read and form action" do
    get admin_categories_path
    assert_response :success
    assert_select "h1", "Категории"

    get admin_category_path(categories(:materials))
    assert_response :success

    get new_admin_category_path
    assert_response :success

    get edit_admin_category_path(categories(:materials))
    assert_response :success
  end

  test "creates a category with allowed parameters only" do
    old_time = 20.years.ago

    assert_difference -> { Category.count }, 1 do
      post admin_categories_path, params: {
        category: {
          name: "Экология",
          slug: "ecology",
          description: "Повторное использование упаковки.",
          created_at: old_time
        }
      }
    end

    category = Category.order(:created_at).last
    assert_redirected_to admin_category_path(category)
    assert_operator category.created_at, :>, 1.minute.ago
  end

  test "renders validation errors with status 422" do
    assert_no_difference -> { Category.count } do
      post admin_categories_path, params: { category: { name: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "[role='alert']"
  end

  test "updates and deletes a category without posts" do
    category = Category.create!(name: "Черновая категория", slug: "temporary-category", description: "Можно удалить")

    patch admin_category_path(category), params: { category: { name: "Новая категория" } }
    assert_redirected_to admin_category_path(category)
    assert_equal "Новая категория", category.reload.name

    assert_difference -> { Category.count }, -1 do
      delete admin_category_path(category)
    end
    assert_redirected_to admin_categories_path
  end

  test "does not delete a category that contains posts" do
    category = categories(:materials)

    assert_no_difference -> { Category.count } do
      delete admin_category_path(category)
    end

    assert_redirected_to admin_category_path(category)
    assert_match(/нельзя удалить/i, flash[:alert])
  end

  private

  def sign_in
    post admin_session_path, params: {
      session: { email: admins(:owner).email, password: "correct-horse-battery" }
    }
  end
end
