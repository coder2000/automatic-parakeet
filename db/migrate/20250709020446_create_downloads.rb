class CreateDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :downloads do |t|
      t.string :ip_address
      t.integer :count, default: 0

      t.belongs_to :user, null: true
      t.belongs_to :download_link

      t.timestamps
    end
  end
end
