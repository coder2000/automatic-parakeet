class CreatePlatforms < ActiveRecord::Migration[8.0]
  def change
    create_table :platforms do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.index :slug, unique: true
      t.index :name, unique: true

      t.timestamps
    end
  end
end
