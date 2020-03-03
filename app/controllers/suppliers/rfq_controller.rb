class Suppliers::RfqController < Suppliers::BaseController
  before_action :get_rfqs, only: :index
  before_action :supplier_rfqs_params, :set_rfq, only: :update

  def index
    authorize :rfq
    @rfqs = SupplierRfq.where(supplier_id: current_company.id)
    service = Services::Suppliers::Finders::SupplierRfqs.new(params, current_suppliers_contact, current_company)
    service.call
    @indexed_rfqs = service.indexed_records
    @rfqs = service.records

    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_rfqs, SupplierRfq)
    status_service.call
    @total_values = status_service.indexed_total_values
  end

  def edit_rfq
    authorize :rfq
    @rfq = SupplierRfq.find(params[:rfq_id])
  end

  def update
    authorize :rfq
    if @rfq.present?
      Services::Suppliers::BuildRevisionHistory.new(@rfq, supplier_rfqs_params).call
      @rfq.assign_attributes(supplier_rfqs_params)
      if @rfq.save
        if @rfq.inquiry_product_suppliers_changed?
          @rfq.update_attributes(status: 'PQ Sent')
          Services::Overseers::Inquiries::UpdateStatus.new(@rfq.inquiry, :pq_received).call if @rfq.inquiry.status != 'PQ Received'
        end
        redirect_to suppliers_rfq_index_path, notice: "Rfq's updated."
      end
    end
  end

  def show
    authorize :rfq
    @rfq = SupplierRfq.find(params[:id])
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

    def set_rfq
      @rfq = SupplierRfq.find(supplier_rfqs_params[:id])
    end

    def supplier_rfqs_params
      params.require(:supplier_rfq).permit(:id,
                                           attachments: [],
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
end
