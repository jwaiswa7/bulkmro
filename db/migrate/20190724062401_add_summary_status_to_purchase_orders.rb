class AddSummaryStatusToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :material_summary_status, :integer
  end
end
