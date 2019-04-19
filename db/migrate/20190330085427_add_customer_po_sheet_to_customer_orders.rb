class AddCustomerPoSheetToCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :customer_po_sheet, :string
  end
end
