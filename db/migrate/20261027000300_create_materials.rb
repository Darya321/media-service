class CreateMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :summary, null: false
      t.text :description, null: false
      t.text :use_cases, null: false
      t.integer :strength_score, null: false, default: 3
      t.integer :print_score, null: false, default: 3
      t.integer :eco_score, null: false, default: 3
      t.integer :cost_score, null: false, default: 3
      t.decimal :price_factor, precision: 6, scale: 3, null: false, default: 1

      t.timestamps
    end

    add_index :materials, :slug, unique: true
  end
end
