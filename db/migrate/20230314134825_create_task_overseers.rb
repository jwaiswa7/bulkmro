class CreateTaskOverseers < ActiveRecord::Migration[5.2]
  def change
    create_table :task_overseers do |t|
      t.references :overseer, foreign_key: true
      t.references :task, foreign_key: true

      t.timestamps
    end
    add_index :task_overseers, [:overseer_id, :task_id], unique: true
  end
end

