class CreateAccountTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :account_targets do |t|

      t.references :account, foreign_key: true, index: true
      t.references :target_period, foreign_key: true, index: true, default: 0
      t.references :annual_target, foreign_key: true, index: true

      t.decimal :target_value
      t.decimal :achieved_target
      t.decimal :achieved_target_percentage

      t.userstamps
      t.timestamps
    end
  end
end
