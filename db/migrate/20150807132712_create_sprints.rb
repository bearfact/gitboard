class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.integer :user_id, null: false
      t.string :owner, null: false
      t.string :name, null: false
      t.datetime :due_date
      t.integer :status, default: 1, null: false
    end
    add_reference :sprints, :users, index: true, foreign_key: true
  end
end
