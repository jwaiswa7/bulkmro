class AddLeadTimeToSalesOrderRows < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_order_rows, :lead_time, :datetime
  end
end
