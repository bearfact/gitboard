class CreateIssuesStatusIssues < ActiveRecord::Migration
  def change
    create_table :issues_status_issues do |t|
    	t.integer :issue_id, null: false, unique: true
    	t.integer :issues_status_id, null: false, default: 1
    	t.integer :last_updated_by_id, null: false
    	t.timestamps
    end

    add_foreign_key(:issues_status_issues, :users, column: 'last_updated_by_id')
    add_index :issues_status_issues, :last_updated_by_id
  end
end
