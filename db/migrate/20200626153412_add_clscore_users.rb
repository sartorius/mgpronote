class AddClscoreUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :client_score, :integer, default: 0
  end
end
