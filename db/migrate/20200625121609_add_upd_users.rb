class AddUpdUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :incharge, :boolean, default: false
    remove_column :users, :owner
  end
end
