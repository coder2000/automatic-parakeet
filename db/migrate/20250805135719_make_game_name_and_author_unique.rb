class MakeGameNameAndAuthorUnique < ActiveRecord::Migration[8.0]
  def change
    add_index :games, [:name, :author], unique: true
  end
end
