class CreateDownloadLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :download_links do |t|
      t.references :game, null: false, foreign_key: true
      t.string :url
      t.string :label
      t.timestamps
    end
  end
end
