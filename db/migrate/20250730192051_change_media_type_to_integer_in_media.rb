class ChangeMediaTypeToIntegerInMedia < ActiveRecord::Migration[8.0]
  def up
    # Add temporary column
    add_column :media, :media_type_temp, :integer, default: 0, null: false

    # Update values based on string values
    execute <<-SQL
      UPDATE media
      SET media_type_temp = CASE
        WHEN media_type = 'screenshot' THEN 0
        WHEN media_type = 'video' THEN 1
        ELSE 0
      END
    SQL

    # Remove old column and rename new one
    remove_column :media, :media_type
    rename_column :media, :media_type_temp, :media_type
  end

  def down
    # Add temporary column
    add_column :media, :media_type_temp, :string, null: false, default: "screenshot"

    # Update values based on integer values
    execute <<-SQL
      UPDATE media
      SET media_type_temp = CASE
        WHEN media_type = 0 THEN 'screenshot'
        WHEN media_type = 1 THEN 'video'
        ELSE 'screenshot'
      END
    SQL

    # Remove old column and rename new one
    remove_column :media, :media_type
    rename_column :media, :media_type_temp, :media_type
  end
end
