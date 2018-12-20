class ChangePoReferenceToStringInCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :customer_orders, :po_reference, :string
  end
end
