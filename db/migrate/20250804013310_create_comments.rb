class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: {to_table: :comments}
      t.text :content, null: false

      t.timestamps
    end

    add_index :comments, [:game_id, :created_at]
    add_index :comments, [:parent_id, :created_at]
  end
end
