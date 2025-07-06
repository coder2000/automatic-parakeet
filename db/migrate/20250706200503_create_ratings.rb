class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.float :rating, default: 0.0, null: false

      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :game, null: false, foreign_key: true

      t.index %i[user_id game_id], unique: true

      t.timestamps
    end
  end
end
