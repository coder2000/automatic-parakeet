class AddColumnsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verified, :boolean, default: false
    add_column :users, :banned_at, :datetime
  end
end
