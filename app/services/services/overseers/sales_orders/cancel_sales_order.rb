class Services::Overseers::SalesOrders::CancelSalesOrder < Services::Shared::BaseService
  def initialize(sales_order, params)
    @sales_order = sales_order
    @sales_order_params = params
  end

  def call
    if sales_order_params['comments_attributes']['0']['message'].present?
      sales_order.assign_attributes(sales_order_params)
      sales_order.save
      if sales_order.remote_uid.present?
        ::Resources::Order.update(sales_order.remote_uid, sales_order)
      end
      @status = true
    else
      @status = false
    end
    @status
  end

  attr_accessor :sales_order, :sales_order_params
end