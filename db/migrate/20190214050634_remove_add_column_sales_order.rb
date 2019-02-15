class RemoveAddColumnSalesOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :sales_orders, :manager_approved_date
    add_column :sales_orders,:manager_so_status_date,:datetime
  end
end
