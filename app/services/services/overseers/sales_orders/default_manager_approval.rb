class Services::Overseers::SalesOrders::DefaultManagerApproval < Services::Shared::BaseService
  def initialize(sales_order, notification)
    @sales_order = sales_order
    @inquiry = @sales_order.inquiry
    @notification = notification
  end

  def call
    @comment = inquiry.comments.build(inquiry: inquiry, sales_order: sales_order, message: 'Approved.', overseer: Overseer.default_approver, show_to_customer: false)

    service = Services::Overseers::SalesOrders::ApproveAndSerialize.new(sales_order, @comment)
    Services::Overseers::Inquiries::UpdateStatus.new(@comment.sales_order, :order_approved_by_sales_manager).call
    service.call

    notification.send_order_comment(
      inquiry.inside_sales_owner,
        :create_confirmation,
        @comment.sales_order,
        Rails.application.routes.url_helpers.overseers_inquiry_comments_path(inquiry, sales_order_id: sales_order.to_param, show_to_customer: false),
        'approve', inquiry.inquiry_number.to_s, @comment.message
    )
  end

  attr_reader :sales_order, :inquiry, :notification
end
