class Overseers::SalesApprovals::SalesOrdersController < Overseers::SalesApprovals::BaseController
  def new
    @sales_order = @sales_approval.build_sales_order(:overseer => current_overseer)
    authorize @inquiry
  end

  def create
    @sales_order = @sales_approval.build_sales_order(sales_order_params.merge(:overseer => current_overseer))
    authorize @inquiry

    if @sales_order.save
      redirect_to overseers_inquiries_path, notice: flash_message(@inquiry, action_name)
    else
      render 'new'
    end
  end

  private
  def sales_order_params
    params.require(:sales_order).permit(
        :comments
    )
  end
end