class AddColumnsToPurchaseOrderQueues < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_queues, :purchase_order_number, :integer
    add_column :purchase_order_queues, :attachments, :string
  end
end
