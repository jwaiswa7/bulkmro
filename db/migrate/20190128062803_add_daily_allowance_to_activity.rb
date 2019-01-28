class AddDailyAllowanceToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :daily_allowance, :decimal, :default => 0.0


  end
end
