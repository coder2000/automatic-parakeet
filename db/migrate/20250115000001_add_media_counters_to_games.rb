class AddMediaCountersToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :screenshots_count, :integer, default: 0, null: false
    add_column :games, :videos_count, :integer, default: 0, null: false

    add_index :games, :screenshots_count
    add_index :games, :videos_count
  end
end
