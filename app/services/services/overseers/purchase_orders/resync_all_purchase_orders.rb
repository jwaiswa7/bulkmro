class Services::Overseers::PurchaseOrders::ResyncAllPurchaseOrders < Services::Shared::BaseService
  def call
    purchase_orders = PurchaseOrder.where(remote_uid: nil, sap_sync: 'Not Sync').order(id: :desc)
    purchase_orders.each do |purchase_order|
      purchase_order.save_and_sync(purchase_order.po_request)
    end
  end
end
