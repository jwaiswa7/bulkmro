class ChangeSkuInSalesShipmentRow < ActiveRecord::Migration[5.2]
  def change
    change_column :sales_shipment_rows, :sku, :string
  end
end