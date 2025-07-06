class CreateDownloadLinksPlatforms < ActiveRecord::Migration[7.1]
  def change
    create_table :download_links_platforms, id: false do |t|
      t.references :download_link, null: false, foreign_key: true
      t.references :platform, null: false, foreign_key: true
    end
    add_index :download_links_platforms, [:download_link_id, :platform_id], unique: true, name: 'index_dl_platforms_on_dl_id_and_platform_id'
  end
end
