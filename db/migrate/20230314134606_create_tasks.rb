class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :task_id
      t.text :subject
      t.integer :status
      t.integer :priority
      t.string :description
      t.integer :company_id
      t.string :department
      t.date :due_date

      t.timestamps
      t.userstamps

    end
  end
end
