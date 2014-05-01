class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.string :owner, null: false
      t.text :description
      t.string :url
      t.timestamps
    end
    #add_foreign_key :repositories, :users
    add_reference :repositories, :users, index: true, foreign_key: true
    add_index :repositories, [:name, :owner, :user_id]
    #add_index :repositories, :user_id
  end
end
