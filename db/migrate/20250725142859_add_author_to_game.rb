class AddAuthorToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :author, :string
  end
end
