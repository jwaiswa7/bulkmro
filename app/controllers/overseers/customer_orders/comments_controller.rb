

class Overseers::CustomerOrders::CommentsController < Overseers::CustomerOrders::BaseController
  def create
    @comment = @customer_order.comments.build(comment_params.merge(overseer: current_overseer))
    authorize @comment
    if @comment.save
      redirect_to overseers_customer_order_path(@customer_order), notice: flash_message(@comment, action_name)
    else
      'new'
    end
  end

  private

    def comment_params
      params.require(:customer_order_comment).permit(
        :message,
          :show_to_customer
      )
    end
end
