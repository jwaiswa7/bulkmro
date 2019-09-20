class Suppliers::RfqController < Suppliers::BaseController
  before_action :get_rfqs, only: :index
  before_action :set_rfq, only: [:edit, :show]
  before_action :product_supplier_params, only: :update

  def index
    authorize :rfq
  end

  def edit
    authorize :rfq
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

  def update_supplier_rfq
    authorize :rfq

  end

  def show
    authorize :rfq
  end

  def edit_supplier_rfq
    authorize :rfq
    supplier = Company.find(params[:supplier_id])
    @inquiry = Inquiry.find(params[:inquiry_id])
    @supplier_rfqs = SupplierRfq.where(inquiry_id: @inquiry.id, supplier_id: supplier.id)
  end

  private

  def get_rfqs
    rfq_ids = SupplierRfq.where(supplier_id: current_company.id).pluck :id
    @product_suppliers = InquiryProductSupplier.where(supplier_rfq_id: rfq_ids, supplier_id: current_company.id)
  end

  def set_rfq
    @inquiry_product_supplier = InquiryProductSupplier.find(params[:id])
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
