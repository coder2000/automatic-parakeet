class CreateNews < ActiveRecord::Migration[7.0]
  def change
    create_table :news do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.timestamps
    end
  end
end
