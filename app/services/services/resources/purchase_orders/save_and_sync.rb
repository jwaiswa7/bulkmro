class Services::Resources::PurchaseOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(purchase_order, po_request = nil)
    @purchase_order = purchase_order
    @po_request = po_request
  end

  def call
    if purchase_order.save
      po_json = ::Resources::PurchaseOrder.custom_find(purchase_order.po_number)
      if po_json.present?
        if po_json['DocEntry'].present?
          doc_entry = po_json['DocEntry']
          purchase_order.update_attributes(remote_uid: doc_entry)
        end
      end

      if !purchase_order.remote_uid.present? && po_request.present?
        doc_num = ::Resources::PurchaseOrder.create(purchase_order, po_request)
        if doc_num.present?
          purchase_order.update_attributes(remote_uid: doc_num, sap_sync: 'Sync')
        end
      end
    end
  end

  attr_accessor :purchase_order, :po_request
end
