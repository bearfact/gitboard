class AddSettingsToUser < ActiveRecord::Migration
  def change
    execute 'create extension hstore;'
    add_column :users, :issues_board_settings, :hstore
  end
end
