class MakeDownloadLinkUrlUnique < ActiveRecord::Migration[8.0]
  def change
    add_index :download_links, :url, unique: true
  end
end
