class AddStatusIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :status_id, :integer, :null => false, :default => 0
  end
end
