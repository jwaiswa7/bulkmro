class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :edit_suppliers, :update_suppliers]
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

    @suppliers = Company.all.map {|x| [x.name, x.id]}

    @inquiry.inquiry_products.each do |ip|
      if ip.inquiry_suppliers.blank?

        if !ip.product.inquiry_suppliers.blank?
          @lowest_price = ip.product.inquiry_suppliers.order(unit_price: :desc).first
          @latest = ip.product.inquiry_suppliers.order(updated_at: :asc).first
          ip.inquiry_suppliers.build(supplier: @lowest_price.supplier, unit_price: @lowest_price.unit_price)
        else

        end

      end
    end
  end

  def update_suppliers
    authorize @inquiry


    begin
      #edit_suppliers_params["inquiry_products_attributes"]["0"]["supplier_ids"].reject!{ |a| a.blank? }


      if @inquiry.update_attributes(edit_suppliers_params.merge(:overseer => current_overseer)) && @inquiry.inquiry_suppliers.size > 0


        redirect_to edit_suppliers_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
      else
        render 'edit_suppliers'
      end
    rescue ActiveRecord::RecordInvalid => e
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
        :inquiry_products_attributes => [:id, :product_id, :quantity, :_destroy]
    )
  end

  def edit_suppliers_params
    params.require(:inquiry).permit(
        :inquiry_products_attributes => [:id, :inquiry_suppliers_attributes => [ :id, :supplier_id, :unit_price, :_destroy]]

    )
  end

end
