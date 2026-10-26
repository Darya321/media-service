class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.text :summary, null: false
      t.text :body, null: false
      t.integer :kind, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.boolean :featured, null: false, default: false
      t.string :cover_asset

      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, %i[status published_at]
  end
end
