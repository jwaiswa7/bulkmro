class Overseers::Inquiries::CommentsController < Overseers::Inquiries::BaseController
  def index
    @sales_order = @inquiry.sales_orders.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @comments = if @sales_order.present?
      @inquiry.comments.where(sales_order_id: [nil, @sales_order.id]).latest
    else
      @inquiry.comments.latest
    end

    @internal_comments = @comments.internal_comments.page(params[:internal]).per(10)
    @customer_comments = @comments.customer_comments.page(params[:customer]).per(10)
    authorize @comments
  end

  def create
    @comment = @inquiry.comments.build(inquiry_comment_params.merge(overseer: current_overseer))

    authorize @comment

    if @comment.sales_order.present? && @comment.save
      callback_method = %w(approve reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@comment.sales_order).send([callback_method, "?"].join)
      redirect_to overseers_inquiry_comments_path(@inquiry, sales_order_id: @comment.sales_order.to_param, show_to_customer: inquiry_comment_params[:show_to_customer]), notice: flash_message(@comment, action_name)
    elsif @comment.save
      redirect_to overseers_inquiry_comments_path(@inquiry, show_to_customer: inquiry_comment_params[:show_to_customer]), notice: flash_message(@comment, action_name)
    else
      render "new"
    end
  end

  private

    def inquiry_comment_params
      params.require(:inquiry_comment).permit(
        :message,
          :sales_order_id,
          :show_to_customer
      )
    end

    def approve
      service = Services::Overseers::SalesOrders::ApproveAndSerialize.new(@comment.sales_order, @comment)
      Services::Overseers::Inquiries::UpdateStatus.new(@comment.sales_order, :order_approved_by_sales_manager).call
      service.call
    end

    def reject
      @comment.sales_order.create_rejection(comment: @comment, overseer: current_overseer)
      @comment.sales_order.update_attributes(status: :'Rejected')
      Services::Overseers::Inquiries::UpdateStatus.new(@comment.sales_order, :order_rejected_by_sales_manager).call
      @comment.sales_order.update_index
    end
end
