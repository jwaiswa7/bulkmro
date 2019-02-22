class ChangeColumnInInvoiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_requests, :material_pickup_request, foreign_key: true
    add_column :purchase_orders, :followup_date, :datetime
  end
end
