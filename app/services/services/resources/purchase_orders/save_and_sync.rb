class Services::Resources::PurchaseOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(purchase_order, po_request = nil)
    @purchase_order = purchase_order
    @po_request = po_request
  end

  def call
    if purchase_order.save
      if purchase_order.persisted?
        if !purchase_order.remote_uid.present? && po_request.present?
          purchase_order.update_attributes(remote_uid: ::Resources::PurchaseOrder.create(purchase_order, po_request))
        end
      end
    end
  end

  attr_accessor :purchase_order, :po_request
end
