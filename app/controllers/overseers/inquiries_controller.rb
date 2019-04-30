class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :edit_suppliers, :update_suppliers, :export, :calculation_sheet, :stages, :relationship_map, :get_relationship_map_json, :resync_inquiry_products, :resync_unsync_inquiry_products]

  def index
    authorize :inquiry

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::Inquiries.new(params, current_overseer)
        service.call

        @indexed_inquiries = service.indexed_records
        @inquiries = service.records

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_inquiries, Inquiry)
        status_service.call
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def kra_report
    authorize :inquiry

    respond_to do |format|
      format.html {
        if params['kra_report'].present?
          @date_range = params['kra_report']['date_range']
        end
      }
      format.json do
        service = Services::Overseers::Finders::KraReports.new(params, current_overseer)
        service.call

        if params['kra_report'].present?
          @date_range = params['kra_report']['date_range']
        end

        @indexed_kra_reports = service.indexed_records.aggregations['kra_over_month']['buckets']['custom-range']['inquiries']['buckets']
      end
    end
  end

  def kra_report_per_sales_owner
    authorize :inquiry

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::Inquiries.new(params, current_overseer)
        service.call

        @indexed_inquiries = service.indexed_records
        @inquiries = service.records
      end
    end
  end

  def export_kra_report
    authorize :inquiry
    service = Services::Overseers::Finders::KraReports.new(params, current_overseer)
    service.call

    indexed_kra_reports = service.indexed_records.aggregations['kra_over_month']['buckets']['custom-range']['inquiries']['buckets']

    if params['kra_report'].present?
      date_range = params['kra_report']['date_range']
    else
      date_range = 'Overall'
    end

    export_service = Services::Overseers::Exporters::KraReportsExporter.new([], current_overseer, indexed_kra_reports, date_range)
    export_service.call

    redirect_to url_for(Export.kra_report.not_filtered.last.report)
  end

  def export_all
    authorize :inquiry
    service = Services::Overseers::Exporters::InquiriesExporter.new([], current_overseer, [])
    service.call

    redirect_to url_for(Export.inquiries.not_filtered.last.report)
  end

  def export_filtered_records
    authorize :inquiry
    service = Services::Overseers::Finders::Inquiries.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::InquiriesExporter.new([], current_overseer, service.records)
    export_service.call
  end

  def export_inquiries_tat
    authorize :inquiry
    service = Services::Overseers::Exporters::InquiriesTatExporter.new([], current_overseer, [])
    service.call
    export = Export.inquiries_tat.not_filtered.last
    export_report = export.report if export.present?
    export_report.present? ? redirect_to(url_for(export_report)) : redirect_to(overseers_inquiries_path, notice: 'Inquiries TAT download failed!')
  end

  def index_pg
    @inquiries = ApplyDatatableParams.to(policy_scope(Inquiry.all.with_includes), params)
    authorize @inquiries
  end

  def smart_queue
    authorize :inquiry

    respond_to do |format|
      format.html do
        summary_service = Services::Overseers::Inquiries::SmartQueueSummary.new
        @statuses = summary_service.call
      end

      format.json do
        service = Services::Overseers::Finders::SmartQueues.new(params, current_overseer)
        service.call

        @indexed_inquiries = service.indexed_records
        @inquiries = service.records.try(:reverse)
      end
    end
  end

  def autocomplete
    service = Services::Overseers::Finders::Inquiries.new(params.merge(page: 1))
    service.call

    @indexed_inquiries = service.indexed_records
    @inquiries = service.records.reverse

    authorize :inquiry
  end

  def show
    authorize @inquiry
    redirect_to edit_overseers_inquiry_path(@inquiry)
  end

  def export
    authorize @inquiry
    render json: Serializers::InquirySerializer.new(@inquiry).serialized_json
  end

  def calculation_sheet
    authorize @inquiry

    send_file(
      "#{Rails.root}/public/calculation_sheet/Calc_Sheet.xlsx",
        filename: "##{@inquiry.inquiry_number} Calculation Sheet.xlsx"
    )
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
      Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :new_inquiry).call if @inquiry.persisted?
      redirect_to edit_overseers_inquiry_path(@inquiry, notice: flash_message(@inquiry, action_name))
    else
      render 'new'
    end
  end

  def edit
    authorize @inquiry
  end

  def update
    @inquiry.assign_attributes(inquiry_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save_and_sync
      Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :cross_reference).call if @inquiry.inquiry_products.present?
      if @inquiry.status == 'Order Lost'
        Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :order_lost).call
      elsif @inquiry.status == 'Regret'
        Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :regret).call
      else
        Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :default).call
      end

      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  def resync_inquiry_products
    authorize @inquiry
    @inquiry_products = @inquiry.products
    @inquiry_products.each do |product|
      product.save_and_sync
    end
    redirect_to(edit_overseers_inquiry_path(@inquiry)) && (return)
  end

  def resync_unsync_inquiry_products
    authorize @inquiry
    @inquiry_products = @inquiry.products
    @inquiry_products.each do |product|
      if product.not_synced?
        product.save_and_sync
      end
    end
    redirect_to(edit_overseers_inquiry_path(@inquiry)) && (return)
  end

  def edit_suppliers
    authorize @inquiry

    service = Services::Overseers::Inquiries::SetDefaultSuppliers.new(@inquiry)
    service.call
  end

  def update_suppliers
    @inquiry.assign_attributes(edit_suppliers_params.merge(overseer: current_overseer))
    authorize @inquiry

    if @inquiry.save_and_sync
      Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :cross_reference).call


      if params.has_key?(:common_supplier_selected)
        Services::Overseers::Inquiries::CommonSupplierSelected.new(@inquiry, params[:inquiry][:common_supplier_id], params[:inquiry_product_ids]).call
        redirect_to edit_suppliers_overseers_inquiry_path(@inquiry)
      else
        redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@inquiry, action_name)
      end
    end
  end

  def stages
    @stages = @inquiry.inquiry_status_records.order(created_at: :asc)
    authorize @inquiry
  end

  def relationship_map
    authorize @inquiry
  end

  def get_relationship_map_json
    authorize @inquiry
    purchase_order = PurchaseOrder.includes(po_request: :sales_order).where(inquiry_id: @inquiry).where(po_requests: {id: nil}, sales_orders: {id: nil})
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@inquiry, @inquiry.sales_quotes, purchase_order).call
    render json: {data: inquiry_json}
  end

  def create_purchase_orders_requests
    @inquiry = Inquiry.find(new_purchase_orders_requests_params[:id])
    authorize @inquiry
    service = Services::Overseers::SalesOrders::UpdatePoRequests.new(@inquiry, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h, true)
    service.call
    Rails.cache.delete(:po_requests)
    redirect_to stock_overseers_po_requests_path
  end

  def preview_stock_po_request
    @inquiry = Inquiry.find(new_purchase_orders_requests_params[:id])
    service = Services::Overseers::SalesOrders::PreviewPoRequests.new(@inquiry, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    @po_requests = service.call

    Rails.cache.write(:po_requests, @po_requests, expires_in: 25.minutes)
    authorize @inquiry
  end

  def pipeline_report
    authorize :inquiry

    respond_to do |format|
      format.html {
        service = Services::Overseers::Finders::PipelineReports.new(params, current_overseer)
        service.call

        @statuses = Inquiry.statuses
        @indexed_pipeline_report = service.indexed_records.aggregations['pipeline_filter']['buckets']['custom-range']['inquiries_over_time']['buckets']
        @indexed_summary_row = service.indexed_records.aggregations['pipeline_filter']['buckets']['custom-range']['summary_row']
        @summary_total = service.indexed_records.aggregations['pipeline_filter']['buckets']['custom-range']['summary_row_total']
      }
    end
  end

  def bulk_update
    authorize :inquiry

    inquiry_numbers = params['bulk_update_inquiries']['inquiries'].split(/\s*,\s*/)
    inquiries = Inquiry.where(inquiry_number: inquiry_numbers)

    if inquiries.present?
      query_params = params['bulk_update_inquiries'].to_enum.to_h
      update_query = query_params.except('inquiries').reject {|_, v| v.blank?}
      if update_query.present?
        inquiries.update_all(update_query)
        redirect_to overseers_inquiries_path, notice: set_flash_message('Selected inquiries updated successfully', 'success')
      else
        render json: {error: 'Please select any one field to update'}, status: 500
      end
    else
      render json: {error: 'No such inquiries present'}, status: 500
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
          :procurement_operations_id,
          :billing_address_id,
          :billing_company_id,
          :shipping_address_id,
          :shipping_company_id,
          :shipping_contact_id,
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
          :valid_end_time,
          :quotation_followup_date,
          :procurement_date,
          :expected_closing_date,
          :quote_category,
          :price_type,
          :potential_amount,
          :freight_option,
          :freight_cost,
          :total_freight_cost,
          :customer_po_number,
          :packing_and_forwarding_option,
          :payment_option_id,
          :weight_in_kgs,
          :customer_po_sheet,
          :final_supplier_quote,
          :copy_of_email,
          :is_sez,
          :calculation_sheet,
          :commercial_terms_and_conditions,
          :comments,
          :product_type,
          supplier_quotes: [],
          inquiry_products_attributes: [:id, :product_id, :sr_no, :quantity, :bp_catalog_name, :bp_catalog_sku, :_destroy]
      )
    end

    def edit_suppliers_params
      if params.has_key?(:inquiry)
        params.require(:inquiry).permit(
          inquiry_products_attributes: [
              :id,
              inquiry_product_suppliers_attributes: [
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

    def new_purchase_orders_requests_params
      if params.has_key?(:inquiry)
        params.require(:inquiry).permit(
          :id,
            po_requests_attributes: [
                :id,
                :supplier_id,
                :inquiry_id,
                :company_id,
                :reason_to_stock,
                :estimated_date_to_unstock,
                :requested_by_id,
                :approved_by_id,
                :_destroy,
                :logistics_owner_id,
                :address_id,
                :contact_id,
                :payment_option_id,
                :stock_status,
                :supplier_committed_date,
                :blobs,
                :supplier_po_type,
                :contact_email,
                :contact_phone,
                :bill_from_id,
                :ship_from_id,
                :bill_to_id,
                :ship_to_id,
                attachments: [],
                rows_attributes: [
                    :id,
                    :_destroy,
                    :status,
                    :quantity,
                    :sales_order_row_id,
                    :product_id,
                    :brand,
                    :tax_code_id,
                    :tax_rate_id,
                    :measurement_unit_id,
                    :unit_price,
                    :conversion,
                    :lead_time,
                    :discount_percentage
                ],
                comments_attributes: [
                    :created_by_id,
                    :updated_by_id,
                    :message
                ]
            ]
        )
      else
        {}
      end
    end
end
