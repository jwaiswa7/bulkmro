class AddColumnQuotationUidToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :quotation_uid, :integer
  end
end
