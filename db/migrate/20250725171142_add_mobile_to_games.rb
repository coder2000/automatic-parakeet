class AddMobileToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :mobile, :boolean, default: false, null: false
  end
end
