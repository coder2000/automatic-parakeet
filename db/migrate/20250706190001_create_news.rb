class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.text :text, null: false

      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
