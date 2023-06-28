class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:show, :edit_material_followup, :update_material_followup, :resync_urgent_po, :resync_po, :cancelled_purchase_modal, :cancelled_purchase_order, :change_material_status, :render_modal_form, :add_comment]

  def index
    authorize_acl :purchase_order
    service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer)
    service.call

    @indexed_purchase_orders = service.indexed_records
    @purchase_orders = service.records.try(:reverse)
    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_purchase_orders, PurchaseOrder, custom_status: nil, main_summary_status: PurchaseOrder.main_summary_statuses)
    status_service.call

    respond_to do |format|
      format.html {
        @statuses = PurchaseOrder.statuses
        @main_summary_statuses = PurchaseOrder.main_summary_statuses
      }
      format.json do
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def manually_closed
    authorize_acl :purchase_order
    service = Services::Overseers::Finders::MaterialReadinessQueues.new(params.merge(is_manually_close: true), current_overseer)
    service.call

    @indexed_purchase_orders = service.indexed_records
    @purchase_orders = service.records.try(:reverse)

    @summary_records = service.get_summary_records(@indexed_purchase_orders)
    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@summary_records, PurchaseOrder, custom_status: 'material_summary_status', main_summary_status: PurchaseOrder.material_summary_statuses)
    status_service.call

    respond_to do |format|
      format.html {
        # @statuses = PurchaseOrder.material_summary_statuses
        @alias_name = 'Followup'
        @main_summary_statuses = PurchaseOrder.material_summary_statuses
      }
      format.json do
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
        @main_summary_statuses = status_service.indexed_main_summary_statuses
      end
    end
    render 'material_readiness_queue'
  end

  def pending_sap_sync
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.where(remote_uid: nil, sap_sync: 'Not Sync').order(id: :desc), params)
    authorize_acl @purchase_orders
    respond_to do |format|
      format.json { render 'pending_sap_sync' }
      format.html { render 'pending_sap_sync' }
    end
  end

  def resync_po
    authorize_acl @purchase_order
    @purchase_order.save_and_sync(@purchase_order.po_request)
    redirect_to pending_sap_sync_overseers_purchase_orders_path
  end

  def resync_urgent_po
    authorize_acl @purchase_order
    if @purchase_order.save_and_sync(@purchase_order.po_request)
      message = "Purchase Order #{@purchase_order.po_number} has been successfully synced."
    else  
      message = "Purchase Order #{@purchase_order.po_number} has not been synced."
    end
    redirect_to pending_sap_sync_overseers_purchase_orders_path, notice: message
  end

  def resync_all_purchase_orders
    authorize_acl :purchase_order
    service = Services::Overseers::PurchaseOrders::ResyncAllPurchaseOrders.new
    service.call
    redirect_to pending_sap_sync_overseers_purchase_orders_path
  end

  def show
    authorize_acl @purchase_order
    @inquiry = @purchase_order.inquiry
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = @purchase_order.get_packing(@metadata)

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for(@purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier})
      end
    end
  end

  def material_readiness_queue
    authorize_acl :purchase_order
    service = Services::Overseers::Finders::MaterialReadinessQueues.new(params, current_overseer)
    service.call

    @indexed_purchase_orders = service.indexed_records
    @purchase_orders = service.records
    @model_name = 'material_readiness_queue'
    @summary_records = service.get_summary_records(@indexed_purchase_orders)
    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@summary_records, PurchaseOrder, custom_status: 'material_summary_status', main_summary_status: PurchaseOrder.material_summary_statuses)
    status_service.call

    respond_to do |format|
      format.html {
        @statuses = PurchaseOrder.material_summary_statuses
        @alias_name = 'Followup'
        @main_summary_statuses = PurchaseOrder.material_summary_statuses
      }
      format.json do
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end

=begin
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params).joins(:po_request).where("po_requests.status = ?", 20).order("purchase_orders.created_at DESC")
=end
    render 'material_readiness_queue'
  end

  def inward_dispatch_pickup_queue
    @status = 'Inward Dispatch Queue'
    @model_name = 'inward_dispatch_pickup_queue'

    base_filter = {
        base_filter_key: 'status',

        base_filter_value: InwardDispatch.statuses['Material Pickup']
    }


    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::InwardDispatches.new(params.merge(base_filter), current_overseer)

        service.call

        @indexed_inward_dispatches = service.indexed_records
        @inward_dispatches = service.records.try(:reverse)
      end
    end

    authorize_acl :inward_dispatch
    render 'inward_dispatch_pickup_queue'
  end

  def inward_dispatch_delivered_queue
    @status = 'Inward Delivered Queue'
    @model_name = 'inward_dispatch_delivered_queue'
    base_filter = {
        base_filter_key: 'status',

        base_filter_value: InwardDispatch.statuses['Material Delivered']
    }


    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::InwardDispatches.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_inward_dispatches = service.indexed_records
        @inward_dispatches = service.records.try(:reverse)
      end
    end

    authorize_acl :inward_dispatch
    render 'inward_dispatch_pickup_queue'
  end

  def cancelled_inward_dispatches
    @status = 'Cancelled Inward Dispatches'

    base_filter = {
        base_filter_key: 'status',

        base_filter_value: InwardDispatch.statuses['Cancelled']
    }


    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::InwardDispatches.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_inward_dispatches = service.indexed_records
        @inward_dispatches = service.records.try(:reverse)
      end
    end

    authorize :inward_dispatch
    # redirect_to cancelled_inward_dispatches_overseers_purchase_orders_path, notice: flash_message(@purchase_order, action_name)
    render 'inward_dispatch_pickup_queue'
  end

  def inward_completed_queue
    @status = 'Inward Completed Queue'
    @model_name = 'inward_completed_queue'
    base_filter = {
        base_filter_key: 'is_inward_completed',
        base_filter_value: true
    }
    service = Services::Overseers::Finders::InwardDispatches.new(params.merge(base_filter), current_overseer)
    service.call

    @indexed_inward_dispatches = service.indexed_records
    @inward_dispatches = service.records

    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_inward_dispatches, InwardDispatch, custom_status: 'ar_invoice_request_status', main_summary_status: InwardDispatch.ar_invoice_request_statuses)
    status_service.call

      respond_to do |format|
        format.html {
          @statuses = InwardDispatch.ar_invoice_request_statuses
          @alias_name = 'Inward completed queue'
          @main_summary_statuses = InwardDispatch.ar_invoice_request_statuses
        }
        format.json do
          @total_values = status_service.indexed_total_values
          @statuses = status_service.indexed_statuses
        end
      end

    authorize :inward_dispatch
    render 'inward_completed_queue'
  end

  def edit_material_followup
    authorize_acl @purchase_order
    @po_request = @purchase_order.po_request
  end

  def change_material_status
    authorize_acl @purchase_order
    if params[:is_manual].present?
      @purchase_order.update_attributes(material_status: 'Manually Closed')
      redirect_to overseers_purchase_orders_path, notice: flash_message(@purchase_order, action_name)
    else
      @purchase_order.update_material_status
      redirect_to material_readiness_queue_overseers_purchase_orders_path, notice: flash_message(@purchase_order, action_name)
    end
  end

  def update_material_followup
    authorize_acl @purchase_order
    @purchase_order.assign_attributes(purchase_order_params)

    if @purchase_order.valid?

      messages = FieldModifiedMessage.for(@purchase_order, ['supplier_dispatch_date', 'revised_supplier_delivery_date', 'followup_date', 'logistics_owner_id'])
      if messages.present?
        @purchase_order.comments.create(message: messages, overseer: current_overseer)
      end

      if @purchase_order.comments.last.message == 'Others'
        @purchase_order.comments.last.message = "Others: #{params[:purchase_order][:other_message]}"
      end
      @purchase_order.save
      redirect_to edit_material_followup_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_material_followup'
    end
  end

  def autocomplete
    purchase_orders = PurchaseOrder.all
    if params[:inquiry_number].present?
      purchase_orders = PurchaseOrder.joins(:inquiry).where(inquiries: {inquiry_number: params[:inquiry_number]})
      purchase_orders = purchase_orders.where(id: purchase_orders.pluck(:id))
    end
    @purchase_orders = ApplyParams.to(purchase_orders, params)

    authorize_acl :purchase_order
  end

  def autocomplete_without_po_requests
    purchase_orders = PurchaseOrder.all
    if params[:inquiry_number].present?
      purchase_orders = PurchaseOrder.joins(:inquiry).where(inquiries: {inquiry_number: params[:inquiry_number]})
      purchase_orders = purchase_orders.where(id: purchase_orders.reject { |r| r.po_request.present? }.pluck(:id))
    end
    @purchase_orders = ApplyParams.to(purchase_orders, params)

    authorize_acl :purchase_order
  end

  def export_all
    authorize_acl :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new([], current_overseer, [])
    service.call

    redirect_to url_for(Export.purchase_orders.not_filtered.completed.last.report)
  end

  def export_filtered_records
    authorize_acl :purchase_order
    service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::PurchaseOrdersExporter.new([], current_overseer, service.records.pluck(:id))
    export_service.call
  end

  def update_logistics_owner
    @purchase_orders = PurchaseOrder.where(id: params[:purchase_orders])
    authorize_acl @purchase_orders
    @purchase_orders.each do |purchase_order|
      purchase_order.update_attributes(logistics_owner_id: params[:logistics_owner_id])
    end
  end

  def update_logistics_owner_for_inward_dispatches
    @inward_dispatches = InwardDispatch.where(id: params[:inward_dispatches])
    authorize_acl @inward_dispatches
    @inward_dispatches.each do |pickup_request|
      pickup_request.update_attributes(logistics_owner_id: params[:logistics_owner_id])
    end
  end

  def export_material_readiness
    authorize_acl :purchase_order

    service = Services::Overseers::Exporters::MaterialReadinessExporter.new([], current_overseer)
    service.call

    redirect_to url_for(Export.material_readiness_queue.not_filtered.completed.last.report)
  end

  def cancelled_purchase_modal
    authorize_acl @purchase_order
    respond_to do |format|
      format.html { render partial: 'cancel_purchase_order', locals: {created_by_id: current_overseer.id} }
    end
  end

  def cancelled_purchase_order
    authorize_acl @purchase_order
    @status = Services::Overseers::PurchaseOrders::CancelPurchaseOrder.new(@purchase_order, purchase_order_params.merge(status: 'Cancelled')).call
    
    if @status.key?(:empty_message) || purchase_order_params[:can_notify_supplier].blank?
      render json: {error: 'Please fill Required Data!'}, status: 500
    elsif @purchase_order.company_id.blank?
      render json: {error: 'Supplier not Exists'}, status: 500
    elsif @status[:status] == 'success' && purchase_order_params[:can_notify_supplier] == 'true'
      cc_addresses = []
      cc_addresses << @purchase_order.inquiry.inside_sales_owner.try(:email) if @purchase_order.inquiry.inside_sales_owner.present?
      cc_addresses << @purchase_order.inquiry.outside_sales_owner.try(:email) if @purchase_order.inquiry.outside_sales_owner.present?
      cc_addresses << @purchase_order.inquiry.sales_manager.try(:email) if @purchase_order.inquiry.sales_manager.present?
      cc_addresses << @purchase_order.logistics_owner.try(:email) if @purchase_order.logistics_owner.present?
      @email_message = @purchase_order.email_messages.build(overseer: current_overseer , purchase_order: @purchase_order,cc: cc_addresses)
      @email_message.assign_attributes(
        to: @purchase_order.supplier.email,
        from: @purchase_order.inquiry.inside_sales_owner.email,
        subject: "Bulk MRO Industrial Supply Pvt Ltd. has cancelled the PO # #{@purchase_order.po_number} sent to #{@purchase_order.supplier.name}",
        body: PoRequestMailer.notify_supplier_of_cancel_purchase_order(@email_message).body.raw_source,
      )
      @metadata = @purchase_order.metadata.deep_symbolize_keys
      @payment_terms = PaymentOption.find_by(remote_uid: @metadata[:PoPaymentTerms])
      @metadata[:packing] = @purchase_order.get_packing(@metadata)
      @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@purchase_order, locals: {inquiry: @purchase_order.inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier, payment_terms: @payment_terms})), filename: @purchase_order.filename(include_extension: true))
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)
        render json: {url: overseers_purchase_orders_path, notice: 'Email Message has been successfully sent '}, status: 200
      else
        render json: {error: {base: 'Something gone wrong. Please try again!'}}, status: 500
      end
    elsif @status[:status] == 'success'
      render json: {url: overseers_purchase_orders_path, notice: @status[:message]}, status: 200
    elsif @status[:status] == 'failed'
      render json: {error: @status[:message]}, status: 500
    end
  end

  def render_modal_form
    authorize_acl @purchase_order
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html { render partial: 'shared/layouts/add_comment', locals: {obj: @purchase_order, url: add_comment_overseers_purchase_order_path(@purchase_order), view_more: nil} }
      end
    end
  end

  def add_comment
    @purchase_order.assign_attributes(purchase_order_params)
    authorize_acl @purchase_order
    if @purchase_order.valid?
      message = params['purchase_order']['comments_attributes']['0']['message']
      if message.present?
        ActiveRecord::Base.transaction do
          @purchase_order.save!
          @purchase_order_comment = PoComment.new(message: message, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @purchase_order.errors}, status: 500
    end
  end

  private

    def get_supplier(purchase_order, product_id)
      if purchase_order.metadata['PoSupNum'].present?
        product_supplier = (Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']) || Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']))
        return product_supplier if purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy?
      end
      if purchase_order.inquiry.final_sales_quote.present?
        product_supplier = purchase_order.inquiry.final_sales_quote.rows.select { |sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id }.first
        product_supplier.supplier if product_supplier.present?
      end
    end

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def purchase_order_params
      params.require(:purchase_order).permit(
        :material_status,
          :supplier_dispatch_date,
          :followup_date,
          :logistics_owner_id,
          :created_by_id,
          :revised_supplier_delivery_date,
          :can_notify_supplier,
          comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
          attachments: []
      )
    end
end
