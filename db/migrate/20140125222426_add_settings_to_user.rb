class AddSettingsToUser < ActiveRecord::Migration
  def change
     add_column :users, :issues_board_settings, :hstore
  end
end
