class RemoveTitleFromScreenshot < ActiveRecord::Migration[8.0]
  def change
    remove_column :media, :title, :string
  end
end
