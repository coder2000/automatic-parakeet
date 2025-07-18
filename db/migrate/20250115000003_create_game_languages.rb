class CreateGameLanguages < ActiveRecord::Migration[7.1]
  def change
    create_table :game_languages do |t|
      t.references :game, null: false, foreign_key: true
      t.string :language_code, null: false
      t.timestamps
    end
    
    add_index :game_languages, [:game_id, :language_code], unique: true
    add_index :game_languages, :language_code
  end
end