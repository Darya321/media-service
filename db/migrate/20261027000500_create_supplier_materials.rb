class CreateSupplierMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_materials do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :material, null: false, foreign_key: true

      t.timestamps
    end

    add_index :supplier_materials, %i[supplier_id material_id], unique: true
  end
end
