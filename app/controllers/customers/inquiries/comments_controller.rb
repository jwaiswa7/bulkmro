# frozen_string_literal: true

class Customers::Inquiries::CommentsController < Customers::Inquiries::BaseController
  def index
    @sales_order = @inquiry.sales_orders.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @comments = if @sales_order.present?
      @inquiry.comments.where(sales_order_id: [nil, @sales_order.id])
    else
      @inquiry.comments.earliest
    end

    authorize @comments
  end

  def create
    @comment = @inquiry.comments.build(inquiry_comment_params.merge(overseer: current_overseer))

    authorize @comment

    if @comment.sales_order.present? && @comment.save
      callback_method = %w[approve reject].detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@comment.sales_order).send([callback_method, '?'].join)
      redirect_to overseers_inquiry_comments_path(@inquiry, sales_order_id: @comment.sales_order.to_param), notice: flash_message(@comment, action_name)
    elsif @comment.save
      redirect_to overseers_inquiry_comments_path(@inquiry), notice: flash_message(@comment, action_name)
    else
      render 'new'
    end
  end

  private

    def inquiry_comment_params
      params.require(:inquiry_comment).permit(
        :message,
        :sales_order_id,
        :show_in_portal
      )
    end

    def approve
      service = Services::Overseers::SalesOrders::ApproveAndSerialize.new(@comment.sales_order, @comment)
      service.call
    end

    def reject
      @comment.sales_order.create_rejection(comment: @comment, overseer: current_overseer)
      @comment.sales_order.update_attributes(status: :Rejected)
      @comment.sales_order.update_index
    end
end
