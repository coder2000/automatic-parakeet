class CreateMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :media do |t|
      t.references :mediable, null: false, polymorphic: true, index: true
      t.string :media_type, null: false
      t.string :title
      t.text :description
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :media, [:mediable_type, :mediable_id, :media_type]
    add_index :media, [:mediable_type, :mediable_id, :position]
  end
end