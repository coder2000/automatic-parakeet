class AddLongDescriptionToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :long_description, :text
  end
end
