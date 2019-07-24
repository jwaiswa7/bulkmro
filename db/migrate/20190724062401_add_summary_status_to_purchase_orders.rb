class AddSummaryStatusToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :followup_status, :integer
    add_column :purchase_orders, :committed_date_status, :integer
  end
end
