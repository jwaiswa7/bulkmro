class RenameColumnDailyAllowanceinActivitytoExpense < ActiveRecord::Migration[5.2]
  def change
    rename_column :activities, :daily_allowance, :expenses
  end
end
