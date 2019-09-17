class Suppliers::RfqController < Suppliers::BaseController
  before_action :get_rfqs, only: :index
  before_action :set_rfq, only: [:edit, :show]
  before_action :product_supplier_params, only: :update

  def index
    authorize :rfq
  end

  def edit
    authorize :rfq
    @inquiry_product_supplier = @rfq.inquiry_product_supplier
  end

  def update
    authorize :rfq
    @inquiry_product_supplier = InquiryProductSupplier.find(product_supplier_params[:id])
    @inquiry_product_supplier.assign_attributes(
      lead_time: product_supplier_params[:lead_time],
      gst: product_supplier_params[:gst],
      unit_freight: product_supplier_params[:unit_freight],
      final_unit_price: product_supplier_params[:final_unit_price],
      total_price: product_supplier_params[:total_price]
    )
    if @inquiry_product_supplier.save
      redirect_to suppliers_rfq_path
    end
  end

  def show
    authorize :rfq
    @inquiry_product_supplier = @rfq.inquiry_product_supplier
  end

  def edit_rfq_redirection
  end

  private

  def get_rfqs
    @rfqs = SupplierRfq.joins(:inquiry_product_supplier).where(inquiry_product_suppliers: {supplier_id: current_company.id})
  end

  def set_rfq
    @rfq = SupplierRfq.find(params[:id])
  end

  def product_supplier_params
    params.require(:inquiry_product_supplier).permit(
      :id,
      :quantity,
      :lead_time,
      :unit_cost_price,
      :gst,
      :unit_freight,
      :final_unit_price,
      :total_price
    )
  end
end
