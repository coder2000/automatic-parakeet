class AddWebsiteAndIndipadToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :website, :string
    add_column :games, :indiepad, :boolean, default: false
  end
end
