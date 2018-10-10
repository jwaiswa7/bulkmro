class RenameDocNumberAndOrderNumberInSalesOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :sales_orders, :doc_number, :draft_uid
    remove_column :sales_orders, :sap_series, :string
  end
end
