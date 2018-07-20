class Overseers::Inquiries::RfqsController < Overseers::Inquiries::BaseController

  def select_suppliers
    authorize @inquiry
  end

  def suppliers_selected
    authorize @inquiry


    begin
      if @inquiry.update_attributes(inquiry_params.merge(:overseer => current_overseer))
        redirect_to generate_rfqs_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
      else
        render 'select_suppliers'
      end
    rescue ActiveRecord::RecordInvalid => e
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