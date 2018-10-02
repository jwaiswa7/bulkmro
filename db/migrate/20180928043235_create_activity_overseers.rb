class CreateActivityOverseers < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_overseers do |t|
      t.references :overseer, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end

    add_index :activity_overseers, [:overseer_id, :activity_id], unique: true
  end
end