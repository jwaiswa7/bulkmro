class Overseers::InquiriesController < Overseers::BaseController
  before_action :set_inquiry, only: [:show, :edit, :update, :edit_suppliers, :update_suppliers, :export, :calculation_sheet, :stages, :relationship_map, :get_relationship_map_json, :resync_inquiry_products, :resync_unsync_inquiry_products, :duplicate]

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
          @category = params['kra_report']['category']
        end
      }
      format.json do
        service = Services::Overseers::Finders::KraReports.new(params, current_overseer)
        service.call

        if params['kra_report'].present?
          @date_range = params['kra_report']['date_range']
          @category = params['kra_report']['category']
        end

        indexed_kra_reports = service.indexed_records.aggregations['kra_over_month']['buckets']['custom-range']['inquiries']['buckets']
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        @indexed_kra_reports = Kaminari.paginate_array(indexed_kra_reports).page(@page).per(@per)
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

    if params['kra_report'].present?
      @date_range = params['kra_report']['date_range']
      @category = params['kra_report']['category']
    end

    indexed_kra_reports = service.indexed_records.aggregations['kra_over_month']['buckets']['custom-range']['inquiries']['buckets']

    kra_params = {}
    if params['kra_report'].present?
      kra_params['date_range'] = params['kra_report']['date_range']
      kra_params['category'] = params['kra_report']['category']
    else
      kra_params['date_range'] = 'Overall'
      kra_params['category'] = 'inside_sales_owner_id'
    end

    export_service = Services::Overseers::Exporters::KraReportsExporter.new([], current_overseer, indexed_kra_reports, kra_params)
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

  def tat_report
    authorize :inquiry

    respond_to do |format|
      service = Services::Overseers::Finders::TatReports.new(params, current_overseer)
      service.call
      format.html {
        @indexed_tat_reports_aggs = service.indexed_records.aggregations['tat_by_sales_owner']['buckets']['custom-range']['inquiry_mapping_tats']['buckets']
        @indexed_tat_reports = service.indexed_records
      }
      format.json do
        @indexed_tat_reports = service.indexed_records
      end
    end
  end

  def sales_owner_status_avg
    authorize :inquiry
    respond_to do |format|
      if params.present?
        params['tat_report'] = params
        @inside_sales_owner = params['tat_report']['inside_sales_owner_id']
        @date_range = params['tat_report']['date_range']
      end
      service = Services::Overseers::Finders::TatReports.new(params, current_overseer)
      service.call
      @indexed_tat_reports = service.indexed_records
      status_avgs = @indexed_tat_reports.aggregations['tat_by_sales_owner']['buckets']['custom-range']['inquiry_mapping_tats']['buckets'].select { |avg| avg['key'] == @inside_sales_owner.to_i }
      unless status_avgs.blank?
        @sales_owner_average_values = status_avgs[0].except('key', 'doc_count')
        statuses = { 'new_inquiry': 0, 'acknowledgment_mail': 0, 'cross_reference': 0, 'preparing_quotation': 0, 'quotation_sent': 0, 'draft_so_appr_by_sales_manager': 0, 'so_reject_by_sales_manager': 0, 'so_draft_pending_acct_approval': 0, 'rejected_by_accounts': 0, 'hold_by_accounts': 0, 'order_won': 0, 'order_lost': 0, 'regret': 0 }
        @status_average = statuses.map { |status, value| {status: status.to_s, value: @sales_owner_average_values[status.to_s].present? ? (@sales_owner_average_values[status.to_s]['value'] / status_avgs.first['doc_count']).round(2) : 0 } }
        format.html { render partial:  'sales_owner_status_average' }
      else
        format.html
      end
    end
  end

  def export_inquiries_tat
    authorize :inquiry
    service = Services::Overseers::Finders::TatReports.new(params, current_overseer, paginate: false)
    service.call

    indexed_tat_reports = service.indexed_records
    export_service = Services::Overseers::Exporters::InquiriesTatExporter.new([], current_overseer, indexed_tat_reports, '')
    export_service.call

    redirect_to url_for(Export.inquiries_tat.not_filtered.last.report)
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

  def duplicate
    @new_inquiry = @inquiry.dup
    authorize @inquiry
    @new_inquiry.inquiry_number = nil
    @new_inquiry.opportunity_uid = nil
    @new_inquiry.project_uid = nil
    @new_inquiry.quotation_uid = nil
    @new_inquiry.status = nil
    @new_inquiry.created_by = current_overseer
    @new_inquiry.duplicated_from = @inquiry.id
    @new_inquiry.inquiry_currency = InquiryCurrency.create(currency_id: @inquiry.currency)

    if @new_inquiry.save
      @inquiry.inquiry_products.each do |inquiry_product|
        new_inquiry_product = inquiry_product.dup
        new_inquiry_product.inquiry_id = @new_inquiry.id
        new_inquiry_product.created_by = current_overseer
        new_inquiry_product.save
      end
      Services::Overseers::Inquiries::UpdateStatus.new(@new_inquiry, :new_inquiry).call if @new_inquiry.persisted?
      redirect_to edit_overseers_inquiry_path(@new_inquiry, notice: set_flash_message('Inquiry Duplicated successfully', 'success'))
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
        @custom_statuses = Inquiry.pipeline_statuses
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
        render json: { error: 'Please select any one field to update' }, status: 500
      end
    else
      render json: { error: 'No such inquiries present' }, status: 500
    end
  end

  def suggestion
    authorize :inquiry
    service = Services::Overseers::Finders::GlobalSearch.new(params)
    service.call

    indexed_records = service.indexed_records
    inquiries = []

    indexed_records.each do |record|
      hash = {}
      hash['text'] = record.attributes['inquiry_number_autocomplete'] if record.attributes['inquiry_number_autocomplete'].present?
      hash['link'] = overseers_inquiry_path(record.attributes['id']) if record.attributes['inquiry_number_autocomplete'].present?
      (inquiries << hash) if !hash.empty?

      hash = {}
      hash['text'] = ['Relationship Map:', record.attributes['inquiry_number_string']].join(' ') if record.attributes['inquiry_number_autocomplete'].present?
      hash['link'] =  relationship_map_overseers_inquiry_path(record.attributes['id']) if record.attributes['inquiry_number_autocomplete'].present?
      (inquiries << hash) if !hash.empty?

      hash = {}
      hash['text'] = record.attributes['final_sales_quote']['inquiry_order_autocomplete'] if record.attributes['final_sales_quote'].present?
      hash['link'] =  overseers_inquiry_sales_quotes_path(record.attributes['id']) if record.attributes['final_sales_quote'].present?
      (inquiries << hash) if !hash.empty?

      hash = {}
      record.attributes['final_sales_orders'].each do |order|
        hash['text'] = order['inquiry_order_autocomplete'] if order['inquiry_order_autocomplete'].present?
        hash['link'] =  overseers_inquiry_sales_orders_path(record.attributes['id']) if order['inquiry_order_autocomplete'].present?
        (inquiries << hash) if !hash.empty?
      end if record.attributes['final_sales_orders'].present?

      hash = {}
      hash['text'] = record.attributes['company']['company_autocomplete'] if record.attributes['company'].present?
      hash['link'] =  overseers_company_path(record.attributes['company']['id']) if record.attributes['company'].present?
      (inquiries << hash) if !hash.empty?

      hash = {}
      record.attributes['products'].each do |order|
        hash['text'] = order['product_autocomplete'] if order['product_autocomplete'].present?
        hash['link'] =  overseers_product_path(order['id']) if order['product_autocomplete'].present?
        (inquiries << hash) if !hash.empty?
      end if record.attributes['products'].present?
    end

    render json: {inquiries: inquiries.uniq}.to_json
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
