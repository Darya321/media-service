require "test_helper"

class Admin::MaterialsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "requires authentication" do
    delete admin_session_path
    get admin_materials_path
    assert_redirected_to new_admin_session_path
  end

  test "renders index show new and edit" do
    get admin_materials_path
    assert_response :success
    assert_select "h1", "Материалы"
    get admin_material_path(materials(:microcorrugated))
    assert_response :success
    get new_admin_material_path
    assert_response :success
    get edit_admin_material_path(materials(:microcorrugated))
    assert_response :success
  end

  test "creates and updates only allowed material fields" do
    assert_difference -> { Material.count }, 1 do
      post admin_materials_path, params: { material: valid_material_params.merge(created_at: 20.years.ago) }
    end
    material = Material.find_by!(slug: "glassine-paper")
    assert_redirected_to admin_material_path(material)
    assert_operator material.created_at, :>, 1.minute.ago

    patch admin_material_path(material), params: { material: { summary: "Обновлённое описание" } }
    assert_redirected_to admin_material_path(material)
    assert_equal "Обновлённое описание", material.reload.summary
  end

  test "rejects invalid scores with status 422" do
    assert_no_difference -> { Material.count } do
      post admin_materials_path, params: { material: valid_material_params.merge(strength_score: 9) }
    end
    assert_response :unprocessable_entity
    assert_select "[role='alert']"
  end

  test "deletes an unused material but protects one used by an inquiry" do
    material = Material.create!(valid_material_params.merge(name: "Удаляемый материал", slug: "deletable-material"))
    assert_difference -> { Material.count }, -1 do
      delete admin_material_path(material)
    end
    assert_redirected_to admin_materials_path

    assert_no_difference -> { Material.count } do
      delete admin_material_path(materials(:microcorrugated))
    end
    assert_redirected_to admin_material_path(materials(:microcorrugated))
    assert_match(/нельзя удалить/i, flash[:alert])
  end

  private

  def valid_material_params
    {
      name: "Глассин",
      slug: "glassine-paper",
      summary: "Тонкая полупрозрачная бумага.",
      description: "Подходит для внутренней упаковки.",
      use_cases: "Косметика, выпечка",
      strength_score: 2,
      print_score: 3,
      eco_score: 4,
      cost_score: 4,
      price_factor: 0.8
    }
  end

  def sign_in
    post admin_session_path, params: { session: { email: admins(:owner).email, password: "correct-horse-battery" } }
  end
end
