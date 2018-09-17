class Overseers::Inquiries::CommentsController < Overseers::Inquiries::BaseController
  #before_action :set_sales_order, only: [:edit, :update]

  def index
    @sales_order = @inquiry.sales_orders.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @comments = @inquiry.comments
    authorize @comments
  end

  def new

  end


  def create
    @comment = @inquiry.comments.build(inquiry_comment_params.merge(:overseer => current_overseer))
    @sales_order = @inquiry.sales_orders.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @comment.sales_order = @sales_order if params[:sales_order_id].present?
    authorize @comment
    if @comment.save
      callback_method = %w(approve reject).detect { |action| params[action] }
      send(callback_method) if callback_method.present? && policy(@sales_order).send([callback_method, '?'].join)
      redirect_to overseers_inquiry_comments_path(@inquiry), notice: flash_message(@comment, action_name)
    else
      render 'new'
    end
  end

  def edit

  end

  def update

  end

  private
  def save
    @sales_order.save
  end

  def save_and_send
    @sales_order.assign_attributes(:sent_at => Time.now)
    @sales_order.save
  end

  def set_sales_order
    @sales_order = @inquiry.sales_orders.find(params[:id])
  end

  def inquiry_comment_params
    params.require(:inquiry_comment).permit(
        :message
    )
  end

  def approve
    service = Services::Overseers::SalesOrders::ApproveAndSerialize.new(@sales_order, @comment)
    service.call
  end

  def reject
    @sales_order.create_rejection(:comment => @comment, :overseer => current_overseer)
  end
end