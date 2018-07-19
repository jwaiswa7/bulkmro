class Overseers::Companies::InquiriesController < Overseers::Companies::BaseController
  before_action :set_inquiry, only: [:edit, :update]

  def new
    @inquiry = @company.inquiries.build(overseer: current_overseer)
    authorize @inquiry
  end

  def create
    @inquiry = @company.inquiries.build(inquiry_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save
      redirect_to select_suppliers_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render :new
    end
  end

  def edit
    authorize @inquiry
  end

  def update
    @inquiry.assign_attributes(inquiry_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save
      redirect_to select_suppliers_overseers_inquiry_rfqs_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render :new
    end
  end

  private
  def set_inquiry
    @inquiry ||= Inquiry.find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(
        :contact_id,
        :billing_address_id,
        :shipping_address_id,
        :comments,
        :inquiry_products_attributes => [:id, :product_id, :quantity]
    )
  end
end
