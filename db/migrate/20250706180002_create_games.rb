class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.integer :release_type, null: false, default: 0
      t.float :rating_avg, null: false, default: 0.0
      t.integer :rating_count, null: false, default: 0
      t.float :rating_abs, null: false, default: 0.0
      t.boolean :adult_content, default: false

      t.belongs_to :user
      t.belongs_to :tool
      t.belongs_to :genre

      t.timestamps
    end
  end
end
