class ChangeTypeOfOrderNumberInSalesOrder < ActiveRecord::Migration[5.2]
  def change
    change_column :sales_orders, :order_number, :bigint
  end
end
