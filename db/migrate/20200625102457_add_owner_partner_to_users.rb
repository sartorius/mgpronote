class AddOwnerPartnerToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :owner, :boolean, default: false
    add_column :users, :partner, :integer, default: 0
  end
end
