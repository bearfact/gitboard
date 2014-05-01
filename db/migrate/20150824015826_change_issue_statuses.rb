class ChangeIssueStatuses < ActiveRecord::Migration
  def change
    change_column :issues_statuses, :repository_id, :integer, null: true
    add_column :issues_statuses, :sprint_id, :integer, null: true
  end
end
