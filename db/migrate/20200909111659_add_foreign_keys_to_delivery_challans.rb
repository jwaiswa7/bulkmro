class AddForeignKeysToDeliveryChallans < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :delivery_challans, :addresses, column: :customer_bill_from_id
    add_foreign_key :delivery_challans, :addresses, column: :customer_ship_from_id
    add_foreign_key :delivery_challans, :warehouses, column: :supplier_bill_from_id
    add_foreign_key :delivery_challans, :warehouses, column: :supplier_ship_from_id
    remove_foreign_key :delivery_challans, :purchase_orders
    remove_column :delivery_challans, :purchase_order_id, :integer
    add_column :delivery_challans, :customer_po_number, :string 
  end
end
