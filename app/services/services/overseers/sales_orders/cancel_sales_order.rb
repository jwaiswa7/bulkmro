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
    comment_attributes = sales_order_params['comments_attributes']['0']
    so_cancellation_reason = "Reason for SO Cancellation: #{comment_attributes['message']}" if comment_attributes['message'].present?
    sales_order.comments.build(message: so_cancellation_reason, created_by_id: comment_attributes['created_by_id'], inquiry_id: comment_attributes['inquiry_id'])
    sales_order['status'] = sales_order_params['status']
    sales_order['remote_status'] = sales_order_params['remote_status']
    sales_order.save
    { status: 'success', message: 'Sales Order Cancelled Successfully' }
  end

  attr_accessor :sales_order, :sales_order_params
end
