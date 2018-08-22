class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :import_from_excel, :import_from_list]
  before_action :set_company, only: [:new]

  def index
    @inquiries = ApplyDatatableParams.to(Inquiry.all, params)
    authorize @inquiries
  end

  def show
    authorize @inquiry
    redirect_to edit_overseers_inquiry_path(@inquiry)
  end

  def new
    @inquiry = @company.inquiries.build(overseer: current_overseer)
    authorize @inquiry
  end

  def import_from_excel
    authorize @inquiry
  end

  def handle_excel
    authorize @inquiry
  end

  def import_from_list
    authorize @inquiry
  end

  def handle_list
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
        :inquiry_products_attributes => [:id, :product_id, :quantity]
    )
  end

  def import_from_excel_params
    params.require(:import_from_excel).permit(
      :excel_text,
    )
  end

  def import_from_list_params
    params.require(:import_from_list).permit(
      :list_text,
    )
  end
end
