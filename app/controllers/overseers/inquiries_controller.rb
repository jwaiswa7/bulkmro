class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :edit_suppliers, :update_suppliers, :export]

  def index
    authorize :inquiry

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::Inquiries.new(params)
        service.call

        @indexed_inquiries = service.indexed_records
        @inquiries = service.records.reverse
      end
    end
  end

  def index_pg
    @inquiries = ApplyDatatableParams.to(Inquiry.all.with_includes, params)
    authorize @inquiries
  end

  def autocomplete
    service = Services::Overseers::Finders::Inquiries.new(params)
    service.call

    @indexed_inquiries = service.indexed_records
    @inquiries = service.records

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
    @company = Company.find(params[:company_id])
    @inquiry = @company.inquiries.build(overseer: current_overseer)
    authorize @inquiry
  end

  def create
    @inquiry = Inquiry.new(inquiry_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save_and_sync
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

    if @inquiry.save_and_sync
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

    if @inquiry.save_and_sync
      redirect_to edit_suppliers_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit_suppliers'
    end
  end

  private

  def set_inquiry
    @inquiry ||= Inquiry.find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(
        :project_uid,
        :company_id,
        :contact_id,
        :industry_id,
        :inside_sales_owner_id,
        :outside_sales_owner_id,
        :sales_manager_id,
        :billing_address_id,
        :shipping_address_id,
        :bill_from_id,
        :ship_from_id,
        :status,
        :opportunity_type,
        :opportunity_source,
        :subject,
        :gross_profit_percentage,
        :quotation_date,
        :customer_committed_date,
        :customer_order_date,
        :quotation_followup_date,
        :procurement_date,
        :expected_closing_date,
        :quote_category,
        :price_type,
        :freight_option,
        :total_freight_cost,
        :customer_po_number,
        :packing_and_forwarding_option,
        :payment_option_id,
        :weight_in_kgs,
        :customer_po_sheet,
        :final_supplier_quote,
        :suppler_quote,
        :copy_of_email,
        :is_sez,
        :calculation_sheet,
        :commercial_terms_and_conditions,
        :comments,
        :inquiry_products_attributes => [:id, :product_id, :sr_no, :quantity, :bp_catalog_name, :bp_catalog_sku, :_destroy]

    )
  end

  def edit_suppliers_params
    if params.has_key?(:inquiry)
      params.require(:inquiry).permit(
          :inquiry_products_attributes => [
              :id,
              :inquiry_product_suppliers_attributes => [
                  :id,
                  :supplier_id,
                  :bp_catalog_name,
                  :bp_catalog_sku,
                  :unit_cost_price,
                  :_destroy
              ]
          ]
      )
    else
      {}
    end
  end

end
