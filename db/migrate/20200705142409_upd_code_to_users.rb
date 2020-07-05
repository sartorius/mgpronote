class UpdCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :client_id
    add_column :users, :client_ref, :integer
  end
end
