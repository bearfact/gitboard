class CreateSprintIssues < ActiveRecord::Migration
  def change
    create_table :sprint_issues do |t|
      t.integer :sprint_id, null: false
      t.string :repository, null: false
      t.string :owner, null: false
      t.integer :issue_number, null: false
      t.float :priority_position, default: 0.0
      t.integer :points, null: false, default: 0

    end
    add_reference :sprint_issues, :sprints, index: true, foreign_key: true
  end
end
