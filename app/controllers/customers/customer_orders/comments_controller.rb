# frozen_string_literal: true

class Customers::CustomerOrders::CommentsController < Customers::CustomerOrders::BaseController
  def create
    @comment = @customer_order.comments.build(comment_params.merge(contact: current_contact))
    authorize @comment

    if @comment.save
      callback_method = %w(approve reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@customer_order).send([callback_method, "?"].join)
      redirect_to customers_customer_order_path(@customer_order), notice: flash_message(@comment, action_name)
    elsif @comment.save
      redirect_to customers_customer_order_path(@customer_order), notice: flash_message(@comment, action_name)
    else
      render "new"
    end
  end

  private

    def comment_params
      params.require(:customer_order_comment).permit(
        :message,
          :show_to_customer
      )
    end

    def approve
      @comment.customer_order.create_approval(customer_order_comment_id: @comment.id, contact: current_contact)
    end

    def reject
      @comment.customer_order.create_rejection(customer_order_comment_id: @comment.id, contact: current_contact)
    end
end
