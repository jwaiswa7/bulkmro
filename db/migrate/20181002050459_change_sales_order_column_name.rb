class ChangeSalesOrderColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :sales_orders, :legacy_request_status, :order_status
  end
end
