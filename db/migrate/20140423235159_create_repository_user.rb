class CreateRepositoryUser < ActiveRecord::Migration
  def change
    create_table :repository_users do |t|
      t.integer :user_id, null: false
      t.integer :repository_id, null: false
      t.foreign_key :users, null: false
      t.foreign_key :repositories, null: false
    end
    add_index :repository_users, :user_id
    add_index :repository_users, :repository_id
  end
end
