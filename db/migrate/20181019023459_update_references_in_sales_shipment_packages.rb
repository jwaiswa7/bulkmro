class UpdateReferencesInSalesShipmentPackages < ActiveRecord::Migration[5.2]
  def change
    remove_reference :sales_shipment_packages, :sales_invoice
  end
end
