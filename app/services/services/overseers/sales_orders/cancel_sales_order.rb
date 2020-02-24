class Services::Overseers::SalesOrders::CancelSalesOrder < Services::Shared::BaseService
  def initialize(sales_order, params)
    @sales_order = sales_order
    @sales_order_params = params
  end

  def call
    if sales_order_params['comments_attributes']['0']['message'].present?
      if sales_order.remote_uid.present?
        remote_status = ::Resources::Order.cancel_document(sales_order)
        if remote_status.key?('status') && remote_status['status'] == 'success'
          @status = sales_order_cancel(sales_order, sales_order_params)
        elsif remote_status.key?('status') && remote_status['status'] == 'failed'
          @status = { status: 'failed', message: remote_status['message'] }
        end
      elsif sales_order.remote_uid.blank?
        @status = sales_order_cancel(sales_order, sales_order_params)
      end
    else
      @status = { empty_message: 'true', message: 'Comment message is required' }
    end
    @status
  end


  def sales_order_cancel(sales_order, sales_order_params)
    sales_order.assign_attributes(sales_order_params)
    sales_order.save
    { status: 'success', message: 'Sales Order Cancelled Successfully' }
  end

  attr_accessor :sales_order, :sales_order_params
end
