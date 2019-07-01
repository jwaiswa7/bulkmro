class Services::Resources::PurchaseOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(purchase_order, po_request = nil)
    @purchase_order = purchase_order
    @po_request = po_request
  end

  def call
    if purchase_order.save
      if purchase_order.persisted?
        if !purchase_order.remote_uid.present? && po_request.present?
          doc_num = ::Resources::PurchaseOrder.create(purchase_order, po_request)
          if doc_num.present?
            purchase_order.update_attributes(remote_uid: doc_num, sap_status: 'Sync')
          end
        end
      end
    end
  end

  attr_accessor :purchase_order, :po_request
end
