class RemoveTrackingNumberIndexFromSalesShipmentPackages < ActiveRecord::Migration[5.2]
  def change
    remove_index :sales_shipment_packages, :tracking_number
  end
end
