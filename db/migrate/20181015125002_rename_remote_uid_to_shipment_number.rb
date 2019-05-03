class RenameRemoteUidToShipmentNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :sales_shipments, :remote_uid, :shipment_number
  end
end
