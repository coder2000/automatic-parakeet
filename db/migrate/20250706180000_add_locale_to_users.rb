class AddLocaleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :locale, :string
    add_index :users, :locale
  end
end
