class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:show, :edit_internal_status, :update_internal_status]

  def index
    authorize :purchase_order
    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer)
        service.call

        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_purchase_orders, PurchaseOrder)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def material_readiness_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params)
    render 'material_readiness_queue'
  end

  def material_pickup_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_pickup_queue, params)
    render 'material_readiness_queue'
  end

  def material_delivered_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_delivered_queue, params)
    render 'material_readiness_queue'
  end

  def edit_internal_status
    authorize @purchase_order
  end

  def update_internal_status
    authorize @purchase_order
    @purchase_order.assign_attributes(purchase_order_params)

    if @purchase_order.valid?
      ActiveRecord::Base.transaction do if @purchase_order.internal_status_changed?
          @po_comment = PoComment.new(:message => "Status Changed: #{@purchase_order.internal_status}", :purchase_order => @purchase_order, :overseer => current_overseer)
          @purchase_order.save!
          @po_comment.save!
        else
          @purchase_order.save!
        end
      end
      redirect_to edit_internal_status_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_internal_status'
    end

  end

  def autocomplete
    if params[:inquiry_number].present?
      @purchase_orders = ApplyParams.to(PurchaseOrder.joins(:inquiry).where(inquiries: {inquiry_number: params[:inquiry_number]}), params)
    else
      @purchase_orders = ApplyParams.to(PurchaseOrder.all, params)
    end

    authorize :purchase_order
  end

  def export_all
    authorize :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new
    service.call

    redirect_to url_for(Export.purchase_orders.last.report)
  end

  def show
    authorize @purchase_order
    @inquiry = @purchase_order.inquiry
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = @purchase_order.get_packing(@metadata)

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for(@purchase_order, locals: { inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier })
      end
    end
  end

  private

  def get_supplier(purchase_order, product_id)
    if purchase_order.metadata['PoSupNum'].present?
      product_supplier = ( Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']) || Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']) )
      return product_supplier if ( purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy? )
    end
    if purchase_order.inquiry.final_sales_quote.present?
      product_supplier = purchase_order.inquiry.final_sales_quote.rows.select {|sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id}.first
      product_supplier.supplier if product_supplier.present?
    end
  end

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
        :internal_status,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end
end