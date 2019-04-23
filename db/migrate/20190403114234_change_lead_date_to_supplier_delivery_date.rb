class ChangeLeadDateToSupplierDeliveryDate < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_dispatch_rows, :supplier_delivery_date, :date
    add_column :inward_dispatches, :other_logistics_partner, :text
  end
end
