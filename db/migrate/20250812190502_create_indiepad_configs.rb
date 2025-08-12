class CreateIndiepadConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :indiepad_configs do |t|
      t.jsonb :data, null: false
      t.references :game, null: false

      t.timestamps
    end
  end
end
