class AddFieldsToSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :order_number, :string
    add_column :sales_orders, :sap_series, :string
    add_column :sales_orders, :remote_uid, :string
    add_column :sales_orders, :doc_number, :string
    add_column :sales_orders, :legacy_request_status, :integer
  end
end
