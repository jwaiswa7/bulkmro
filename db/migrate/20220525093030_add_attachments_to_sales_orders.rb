class AddAttachmentsToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :attachments, :string
  end
end
