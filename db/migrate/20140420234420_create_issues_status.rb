class CreateIssuesStatus < ActiveRecord::Migration
  def change
    create_table :issues_statuses do |t|
      t.integer :repository_id, null: false
      t.integer :position, null: false
      t.string :name, null: false
      t.string :label, null: false
      t.foreign_key :repositories, null: false
      t.timestamps
    end
    add_index :issues_statuses, :repository_id
  end
end
