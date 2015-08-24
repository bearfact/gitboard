class CreateIssuesStatus < ActiveRecord::Migration
  def change
    create_table :issues_statuses do |t|
      t.integer :repository_id, null: false
      t.integer :position, null: false
      t.string :name, null: false
      t.string :label, null: false
      t.timestamps
    end
    add_reference :issues_statuses, :repositories, index: true, foreign_key: true
    #add_foreign_key :issues_statuses, :repositories
    #add_index :issues_statuses, :repository_id
  end
end
