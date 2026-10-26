class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :company_type, null: false, default: 0
      t.string :specialization, null: false
      t.text :description, null: false
      t.integer :minimum_order, null: false, default: 0
      t.decimal :unit_price_from, precision: 10, scale: 2, null: false, default: 0
      t.text :regions, null: false, default: "[]"
      t.text :services, null: false, default: "[]"
      t.string :contact_email
      t.string :contact_url
      t.boolean :promoted, null: false, default: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :suppliers, :slug, unique: true
    add_index :suppliers, %i[active company_type]
  end
end
