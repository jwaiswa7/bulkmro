class Overseers::SalesOrders::CommentsController < Overseers::SalesOrders::BaseController
  def index
    @comments = @sales_order.comments
    authorize @comments
  end

  def create
    @comment = @sales_order.comments.build(sales_order_comment_params.merge(:overseer => current_overseer))

    authorize @comment

    if @comment.save
      callback_method = %w(approve reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@sales_order).send([callback_method, '?'].join)

      redirect_to overseers_sales_order_comments_path(@sales_order), notice: flash_message(@comment, action_name)
    else
      render 'new'
    end
  end

  private
  def sales_order_comment_params
    params.require(:sales_order_comment).permit(
        :message
    )
  end

  def approve
    @sales_order.create_approval(:comment => @comment, :overseer => current_overseer)
  end

  def reject
    @sales_order.create_rejection(:comment => @comment, :overseer => current_overseer)
  end
end