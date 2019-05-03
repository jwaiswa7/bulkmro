class RenameTablePoRequestAndComments < ActiveRecord::Migration[5.2]
  def change
    rename_table :purchase_order_queues, :po_requests
    rename_table :purchase_order_comments, :po_request_comments
    rename_column :po_request_comments, :purchase_order_queue_id, :po_request_id
  end
end
