class AddDraftSyncDateSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders,:draft_sync_date,:datetime
  end
end
