class CreateRepositoryUser < ActiveRecord::Migration
  def change
    create_table :repository_users do |t|
      t.integer :user_id, null: false
      t.integer :repository_id, null: false
    end
    add_reference :repository_users, :users, index: true, foreign_key: true
    add_reference :repository_users, :repositories, index: true, foreign_key: true
    # add_foreign_key :repository_users, :users
    # add_foreign_key :repository_users, :repositories
    # add_index :repository_users, :user_id
    # add_index :repository_users, :repository_id
  end
end
