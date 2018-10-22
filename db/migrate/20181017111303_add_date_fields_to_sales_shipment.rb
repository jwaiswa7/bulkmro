class AddDateFieldsToSalesShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_shipments, :followup_date, :date
    add_column :sales_shipments, :delivery_date, :date
    add_column :sales_shipments, :shipment_grn, :string
    add_column :sales_shipments, :packing_remarks, :string
  end
end
