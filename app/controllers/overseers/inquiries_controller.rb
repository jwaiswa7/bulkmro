class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :edit_suppliers, :update_suppliers, :export]
  before_action :set_company, only: [:new]

  def index
    @inquiries = ApplyDatatableParams.to(Inquiry.all, params)
    authorize @inquiries
  end

  def show
    authorize @inquiry
    redirect_to edit_overseers_inquiry_path(@inquiry)
  end

  def export
    authorize @inquiry
    render json: Serializers::InquirySerializer.new(@inquiry).serialized_json
  end

  def new
    @inquiry = @company.inquiries.build(overseer: current_overseer)
    authorize @inquiry
  end

  def create
    @inquiry = Inquiry.new(inquiry_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
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
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render :new
    end
  end

  def edit_suppliers
    authorize @inquiry

    service = Services::Overseers::Inquiries::SetDefaultSuppliers.new(@inquiry)
    service.call
  end

  def update_suppliers
    @inquiry.assign_attributes(edit_suppliers_params.merge(:overseer => current_overseer))
    authorize @inquiry

    if @inquiry.save
      redirect_to edit_suppliers_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit_suppliers'
    end
  end

  private
  def set_company
    @company ||= Company.find(params[:company_id])
  end

  def set_inquiry
    @inquiry ||= Inquiry.find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(
        :company_id,
        :contact_id,
        :billing_address_id,
        :shipping_address_id,
        :comments,
        :inquiry_products_attributes => [:id, :product_id, :position, :quantity, :_destroy]
    )
  end

  def edit_suppliers_params
    params.require(:inquiry).permit(
        :inquiry_products_attributes => [:id, :inquiry_product_suppliers_attributes => [:id, :supplier_id, :unit_cost_price, :_destroy]]
    )
  end

end
