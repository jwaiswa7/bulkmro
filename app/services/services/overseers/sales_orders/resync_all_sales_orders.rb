class Services::Overseers::SalesOrders::ResyncAllSalesOrders < Services::Shared::BaseService
  def call
    sales_orders = SalesOrder.where.not(sent_at: nil).where(remote_uid: nil, status: :'Approved').where("created_at >= '2019-07-18'")
    if sales_orders.present?
      sales_orders.each do |sales_order|
        if sales_order.order_number.present?
          sales_order.save_and_sync
        end
      end
    end
  end
end
