class CreateStats < ActiveRecord::Migration[8.0]
  def change
    create_table :stats do |t|
      t.integer :downloads, default: 0, null: false
      t.integer :visits, default: 0, null: false

      t.belongs_to :game

      t.index [:game_id, :created_at], unique: true

      t.timestamps
    end
  end
end
