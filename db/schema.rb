# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_27_000900) do
  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "inquiries", force: :cascade do |t|
    t.integer "supplier_id"
    t.integer "material_id", null: false
    t.string "email", null: false
    t.string "product_type", null: false
    t.integer "length_mm", null: false
    t.integer "width_mm", null: false
    t.integer "height_mm", null: false
    t.integer "weight_grams"
    t.boolean "fragile", default: false, null: false
    t.integer "quantity", null: false
    t.decimal "budget", precision: 12, scale: 2
    t.date "deadline"
    t.string "region", null: false
    t.string "print_option", default: "none", null: false
    t.text "extras", default: "[]"
    t.decimal "estimated_unit_price", precision: 10, scale: 2
    t.decimal "estimated_total_price", precision: 12, scale: 2
    t.decimal "estimated_low_price", precision: 12, scale: 2
    t.decimal "estimated_high_price", precision: 12, scale: 2
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_inquiries_on_material_id"
    t.index ["status"], name: "index_inquiries_on_status"
    t.index ["supplier_id"], name: "index_inquiries_on_supplier_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "summary", null: false
    t.text "description", null: false
    t.text "use_cases", null: false
    t.integer "strength_score", default: 3, null: false
    t.integer "print_score", default: 3, null: false
    t.integer "eco_score", default: 3, null: false
    t.integer "cost_score", default: 3, null: false
    t.decimal "price_factor", precision: 6, scale: 3, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_materials_on_slug", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.text "summary", null: false
    t.text "body", null: false
    t.integer "kind", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "published_at"
    t.boolean "featured", default: false, null: false
    t.string "cover_asset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["status", "published_at"], name: "index_posts_on_status_and_published_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscriptions_on_email", unique: true
  end

  create_table "supplier_materials", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "material_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_supplier_materials_on_material_id"
    t.index ["supplier_id", "material_id"], name: "index_supplier_materials_on_supplier_id_and_material_id", unique: true
    t.index ["supplier_id"], name: "index_supplier_materials_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "company_type", default: 0, null: false
    t.string "specialization", null: false
    t.text "description", null: false
    t.integer "minimum_order", default: 0, null: false
    t.decimal "unit_price_from", precision: 10, scale: 2, default: "0.0", null: false
    t.text "regions", default: "[]", null: false
    t.text "services", default: "[]", null: false
    t.string "contact_email"
    t.string "contact_url"
    t.boolean "promoted", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "company_type"], name: "index_suppliers_on_active_and_company_type"
    t.index ["slug"], name: "index_suppliers_on_slug", unique: true
  end

  add_foreign_key "inquiries", "materials"
  add_foreign_key "inquiries", "suppliers"
  add_foreign_key "posts", "categories"
  add_foreign_key "supplier_materials", "materials"
  add_foreign_key "supplier_materials", "suppliers"
end
