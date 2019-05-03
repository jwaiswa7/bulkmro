class CreateTarget < ActiveRecord::Migration[5.2]
  def change
    create_table :targets do |t|
      t.references :overseer, foreign_key: true, index: true
      t.references :target_period, foreign_key: true, index: true

      t.integer :target_type
      t.integer :target_value

      t.integer :legacy_id, index: true

      t.userstamps
      t.timestamps
    end
  end
end
