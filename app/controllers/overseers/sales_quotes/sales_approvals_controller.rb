class Overseers::SalesQuotes::SalesApprovalsController < Overseers::SalesQuotes::BaseController
  def new
    @sales_approval = @sales_quote.build_sales_approval(:overseer => current_overseer)
    authorize @inquiry
  end

  def create
    @sales_approval = @sales_quote.build_sales_approval(sales_approval_params.merge(:overseer => current_overseer))
    authorize @inquiry

    if @sales_approval.save
      redirect_to overseers_inquiries_path, notice: flash_message(@inquiry, action_name)
    else
      render 'new'
    end
  end

  private
  def sales_approval_params
    params.require(:sales_approval).permit(
        :comments
    )
  end
end