class AddRevisedDeliveryDateInSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :revised_committed_delivery_date, :date
    add_column :sales_orders, :revised_committed_delivery_attachments, :string
    add_column :inquiry_comments, :revised_committed_delivery_date, :boolean, default: false
  end
end
