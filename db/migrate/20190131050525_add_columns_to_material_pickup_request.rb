class AddColumnsToMaterialPickupRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :material_pickup_requests, :dispatched_by, :string
    add_column :material_pickup_requests, :shipped_to, :string
    add_column :material_pickup_requests, :logistics_partner, :string
    add_column :material_pickup_requests, :tracking_number, :string
  end
end
