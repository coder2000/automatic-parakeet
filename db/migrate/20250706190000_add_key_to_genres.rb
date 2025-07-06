class AddKeyToGenres < ActiveRecord::Migration[7.0]
  def change
    add_column :genres, :key, :string, null: false, default: ''
    add_index :genres, :key, unique: true
  end
end
