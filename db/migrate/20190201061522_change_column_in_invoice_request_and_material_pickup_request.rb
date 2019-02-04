class ChangeColumnInInvoiceRequestAndMaterialPickupRequest < ActiveRecord::Migration[5.2]
  def change
    remove_reference :invoice_requests, :material_pickup_request
    add_reference :material_pickup_requests, :invoice_request, foreign_key: true
  end
end
