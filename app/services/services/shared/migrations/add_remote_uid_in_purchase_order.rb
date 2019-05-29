class Services::Shared::Migrations::AddRemoteUidInPurchaseOrder < Services::Shared::Migrations::Migrations
  def add_remote_uid
    purchase_orders = PurchaseOrder.where.not(po_number: nil)
    purchase_orders.each do |purchase_order|
      po_json = ::Resources::PurchaseOrder.custom_find(purchase_order.po_number)
      if po_json.present?
        if po_json['DocEntry'].present?
          doc_entry = po_json['DocEntry']
          purchase_order.update_attributes(remote_uid: doc_entry)
        end
      end
    end
  end
end