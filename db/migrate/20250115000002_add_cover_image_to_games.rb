class AddCoverImageToGames < ActiveRecord::Migration[8.0]
  def change
    add_reference :games, :cover_image, null: true, foreign_key: {to_table: :media}
  end
end
