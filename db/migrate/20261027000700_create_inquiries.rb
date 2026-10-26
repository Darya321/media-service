class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.references :supplier, null: true, foreign_key: true
      t.references :material, null: false, foreign_key: true
      t.string :email, null: false
      t.string :product_type, null: false
      t.integer :length_mm, null: false
      t.integer :width_mm, null: false
      t.integer :height_mm, null: false
      t.integer :weight_grams
      t.boolean :fragile, null: false, default: false
      t.integer :quantity, null: false
      t.decimal :budget, precision: 12, scale: 2
      t.date :deadline
      t.string :region, null: false
      t.string :print_option, null: false, default: "none"
      t.text :extras, null: false, default: "[]"
      t.decimal :estimated_unit_price, precision: 10, scale: 2
      t.decimal :estimated_total_price, precision: 12, scale: 2
      t.decimal :estimated_low_price, precision: 12, scale: 2
      t.decimal :estimated_high_price, precision: 12, scale: 2
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :inquiries, :status
  end
end
