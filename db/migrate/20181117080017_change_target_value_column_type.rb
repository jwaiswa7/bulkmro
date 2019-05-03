class ChangeTargetValueColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :targets, :target_value, :decimal
  end
end
