class Services::Resources::PurchaseOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def call
    if purchase_order.save
      perform_later(purchase_order)
    end
  end

  def call_later
    if purchase_order.persisted?
      if !purchase_order.remote_uid.present?
        binding.pry
        purchase_order.update_attributes(remote_uid: ::Resources::PurchaseOrder.create(purchase_order, purchase_order.po_request))
      end
    end
  end

  attr_accessor :purchase_order
end
