class AddYoutubeUrlToMedia < ActiveRecord::Migration[7.0]
  def change
    add_column :media, :youtube_url, :string
  end
end
