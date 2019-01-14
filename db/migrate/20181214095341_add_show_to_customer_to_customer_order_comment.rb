class AddShowToCustomerToCustomerOrderComment < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_order_comments, :show_to_customer, :boolean
  end
end
