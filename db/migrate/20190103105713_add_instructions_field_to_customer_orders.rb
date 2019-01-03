class AddInstructionsFieldToCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :special_instructions, :text, default: nil
  end
end
