class Suppliers::RfqController < Suppliers::BaseController
  before_action :get_rfqs, only: :index
  before_action :supplier_rfqs_params, :set_rfq, only: :update
  before_action :ips_params, only: :update_ips
  before_action :set_ips, only: [:edit, :show]

  def index
    authorize :rfq
  end

  def edit_rfq
    authorize :rfq
    @rfq = SupplierRfq.find(params[:rfq_id])
  end

  def update_ips
    authorize :rfq
    inquiry_product_supplier = InquiryProductSupplier.find(ips_params[:id])
    inquiry_product_supplier.assign_attributes(ips_params)
    Services::Suppliers::BuildFromInquiryProductSupplier.new(inquiry_product_supplier, ips_params).call
    if inquiry_product_supplier.save
      redirect_to suppliers_rfq_path(inquiry_product_supplier.id)
    end
  end

  def update
    authorize :rfq
    if @rfq.present?
      Services::Suppliers::BuildFromInquiryProductSupplier.new(@rfq, supplier_rfqs_params).call
      @rfq.assign_attributes(supplier_rfqs_params)
      if @rfq.save
        redirect_to suppliers_rfq_index_path, notice: "Rfq's updated."
      end
    end
  end

  def show
    authorize :rfq
  end

  def edit_supplier_rfqs
    authorize :rfq
    supplier = Company.find(params[:supplier_id])
    @inquiry = Inquiry.find(params[:inquiry_id])
    @supplier_rfqs = SupplierRfq.joins(:inquiry_product_suppliers).where(inquiry_id: @inquiry.id, supplier_id: supplier.id).uniq
  end

  private

    def get_rfqs
      @rfqs = SupplierRfq.where(supplier_id: current_company.id)
      # @product_suppliers = InquiryProductSupplier.where(supplier_rfq_id: rfq_ids, supplier_id: current_company.id)
    end

    def set_ips
      @inquiry_product_supplier = InquiryProductSupplier.find(params[:id])
    end

    def set_rfq
      @rfq = SupplierRfq.find(supplier_rfqs_params[:id])
    end

    def supplier_rfqs_params
      params.require(:supplier_rfq).permit(:id,
                                           inquiry_product_suppliers_attributes: [:id,
                                                                                  :quantity,
                                                                                  :lead_time,
                                                                                  :last_unit_price,
                                                                                  :unit_cost_price,
                                                                                  :gst,
                                                                                  :unit_freight,
                                                                                  :final_unit_price,
                                                                                  :total_price,
                                                                                  :remarks]
      )
    end

    def ips_params
      params.require(:inquiry_product_supplier).permit(
        :id,
        :quantity,
        :lead_time,
        :last_unit_price,
        :unit_cost_price,
        :gst,
        :unit_freight,
        :final_unit_price,
        :total_price,
        :remarks
      )
    end
end
