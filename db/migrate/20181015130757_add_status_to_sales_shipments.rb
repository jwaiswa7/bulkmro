class AddStatusToSalesShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_shipments, :status, :integer
  end
end
