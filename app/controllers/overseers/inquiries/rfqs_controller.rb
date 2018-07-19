class Overseers::Inquiries::RfqsController < Overseers::Inquiries::BaseController

  def select_suppliers
    authorize @inquiry
  end

  def suppliers_selected
    authorize @inquiry

    # TODO redo validation
    # s_products = inquiry_params[:inquiry_products_attributes].to_unsafe_h.map { |k, v| v[:supplier_ids] }.reject { |x| x.reject(&:blank?).size }

    if @inquiry.update(inquiry_params.merge(:overseer => current_overseer))
      redirect_to generate_rfqs_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'select_suppliers'
    end
  end

  def generate_rfqs
    authorize @inquiry
  end

  def rfqs_generated
    authorize @inquiry
  end

  private
  def inquiry_params
    params.require(:inquiry).permit(
        :inquiry_products_attributes => [:id, :supplier_ids => []]
    )
  end
end