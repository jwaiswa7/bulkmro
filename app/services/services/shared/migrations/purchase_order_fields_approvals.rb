class Services::Shared::Migrations::PurchaseOrderFieldsApprovals < Services::Shared::BaseService
  def initialize
    @purchase_orders = PurchaseOrder.where("created_at >= '2019-07-18'")
  end

  def call
    purchase_orders.each do |po|
      if po.remote_uid.present? && po.po_number.present?
        ::Resources::PurchaseOrder.create_approval_purchase_order_fields(po.remote_uid)
      end
    end
  end

  attr_accessor :purchase_orders
end
