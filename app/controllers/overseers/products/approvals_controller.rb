class Overseers::Products::ApprovalsController < Overseers::Products::BaseController
  def create
    @product_approval = @product.build_approval(product_approval_params.merge(:overseer => current_overseer))
    authorize @product_approval

    if @product_approval.save

      redirect_to pending_overseers_products_path, notice: flash_message(@product_approval, action_name)
    else
      render 'new'
    end
  end

  private
  def product_approval_params
    params.require(:product_approval).permit(
        :comments
    )
  end
end