class AddCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :client_id, :string
    add_index :users, :client_id, unique: true
  end
end
