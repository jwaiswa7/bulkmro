class Services::Shared::Migrations::AddCompanyToPurchaseOrder < Services::Shared::Migrations::Migrations
  def call
    partial_purchase_orders = PurchaseOrder.joins(:inward_dispatches).select('inward_dispatches.purchase_order_id').group('inward_dispatches.purchase_order_id').having('count(inward_dispatches.purchase_order_id)>1')
    partial_purchase_orders.each do |partial_purchase_order|
      purchase_order = PurchaseOrder.find(partial_purchase_order.purchase_order_id)
      if purchase_order.present?
        purchase_order.update_attributes(is_partial: true)
      end
    end
  end
end