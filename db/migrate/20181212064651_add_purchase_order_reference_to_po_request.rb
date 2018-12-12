class AddPurchaseOrderReferenceToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :po_requests, :purchase_order, foreign_key: true
  end
end
