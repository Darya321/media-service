require "test_helper"

class Admin::SuppliersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "requires authentication" do
    delete admin_session_path
    get admin_suppliers_path
    assert_redirected_to new_admin_session_path
  end

  test "renders index show new and edit" do
    get admin_suppliers_path
    assert_response :success
    assert_select "h1", "Поставщики"
    get admin_supplier_path(suppliers(:kraft_factory))
    assert_response :success
    get new_admin_supplier_path
    assert_response :success
    get edit_admin_supplier_path(suppliers(:kraft_factory))
    assert_response :success
  end

  test "creates supplier and normalizes regions services and materials" do
    assert_difference -> { Supplier.count }, 1 do
      post admin_suppliers_path, params: {
        supplier: valid_supplier_params.merge(
          regions_text: "Москва, Казань\nМосква",
          services_text: "Печать\nВырубка",
          material_ids: [ materials(:craft_cardboard).id, materials(:microcorrugated).id ],
          created_at: 20.years.ago
        )
      }
    end

    supplier = Supplier.find_by!(slug: "paper-lab")
    assert_redirected_to admin_supplier_path(supplier)
    assert_equal [ "Москва", "Казань" ], supplier.regions
    assert_equal [ "Печать", "Вырубка" ], supplier.services
    assert_equal 2, supplier.materials.count
    assert supplier.active?
    assert supplier.promoted?
    assert_operator supplier.created_at, :>, 1.minute.ago
  end

  test "replaces material assignments and flags on update" do
    supplier = suppliers(:kraft_factory)

    patch admin_supplier_path(supplier), params: {
      supplier: {
        material_ids: [ materials(:craft_cardboard).id ],
        regions_text: "Тула",
        services_text: "Дизайн",
        active: "0",
        promoted: "0"
      }
    }

    assert_redirected_to admin_supplier_path(supplier)
    supplier.reload
    assert_equal [ materials(:craft_cardboard) ], supplier.materials.to_a
    assert_equal [ "Тула" ], supplier.regions
    assert_equal [ "Дизайн" ], supplier.services
    refute supplier.active?
    refute supplier.promoted?
  end

  test "renders invalid supplier with status 422 and can delete a safe record" do
    post admin_suppliers_path, params: { supplier: valid_supplier_params.merge(regions_text: "", services_text: "") }
    assert_response :unprocessable_entity
    assert_select "[role='alert']"

    supplier = suppliers(:inactive_studio)
    assert_difference -> { Supplier.count }, -1 do
      delete admin_supplier_path(supplier)
    end
    assert_redirected_to admin_suppliers_path
  end

  private

  def valid_supplier_params
    {
      name: "Бумажная лаборатория",
      slug: "paper-lab",
      company_type: "factory",
      specialization: "Малая фабрика",
      description: "Производит небольшие партии упаковки.",
      minimum_order: 100,
      unit_price_from: 12.5,
      contact_email: "hello@paper.example",
      contact_url: "https://paper.example",
      promoted: "1",
      active: "1"
    }
  end

  def sign_in
    post admin_session_path, params: { session: { email: admins(:owner).email, password: "correct-horse-battery" } }
  end
end
