class AddPromotionFieldsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :supplier, null: true, foreign_key: { on_delete: :nullify }
    add_column :posts, :placement, :integer, default: 0, null: false
    add_column :posts, :cta_label, :string
    add_column :posts, :external_url, :string

    add_index :posts, :placement
  end
end
