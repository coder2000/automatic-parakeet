# frozen_string_literal: true

class CreateSiteSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :site_settings, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :logo_alt_text, null: false, default: "Website Logo"
      t.timestamps
    end

    # Create the singleton record
    reversible do |direction|
      direction.up do
        execute "INSERT INTO site_settings (id, logo_alt_text, created_at, updated_at) VALUES ('main', 'Website Logo', NOW(), NOW())"
      end
    end
  end
end
