class RemoveLabelFromDownloadLink < ActiveRecord::Migration[8.0]
  def change
    remove_column :download_links, :label, type: :string
  end
end
