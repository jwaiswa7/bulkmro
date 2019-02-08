class AddBillingShippingToPoRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :po_requests, :address_id, :integer

    add_column :po_requests, :bill_from_id, :integer, index: true
    add_column :po_requests, :ship_from_id, :integer, index: true
    add_column :po_requests, :bill_to_id, :integer, index: true
    add_column :po_requests, :ship_to_id, :integer, index: true

    add_foreign_key :po_requests, :addresses, column: :bill_from_id
    add_foreign_key :po_requests, :addresses, column: :ship_from_id
    add_foreign_key :po_requests, :warehouses, column: :bill_to_id
    add_foreign_key :po_requests, :warehouses, column: :ship_to_id
  end
end
