class AddAuthorIndexOnGame < ActiveRecord::Migration[8.0]
  def change
    add_index :games, :author
  end
end
