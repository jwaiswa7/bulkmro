class Services::Overseers::Exporters::MaterialReadinessExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = PurchaseOrder
    @export_name = 'material_readiness_queue'
    @path = Rails.root.join('tmp', filename)
    @columns = ['PO Request', 'Inquiry', 'Customer Company Name', 'Material Status', 'Supplier PO', 'Supplier PO Date', 'Supplier Name', 'PO Type', 'Comments(Latest First)', 'Sales Order Date', 'Sales Order', 'Committed Date to Customer', 'IS&P', 'Logistics Owner', 'Material Follow Up Date', 'Expected Delivery Date', 'Payment Request status', 'Percentage Paid', 'Requested Date', 'Buying Price', 'Selling Price', 'PO Margin %', 'Overall Margin %']
  end

  def call
    perform_export_later('MaterialReadinessExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name, true, @export_time).deliver_now
    @export = Export.create!(export_type: 96, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    service = Services::Overseers::Finders::MaterialReadinessQueues.new({}, @overseer, paginate: false)
    service.call
    service.records.find_each(batch_size: 100) do |record|
      rows.push(
        po_request: record.po_request.present? ? record.po_request.id : '-',
        inquiry_number: record.inquiry.inquiry_number,
        company_name: record.inquiry.company.try(:name),
        material_status: record.material_status,
        supplier_po: record.po_number,
        supplier_po_date: (record.po_date ? format_succinct_date(record.po_date) : '-'),
        supplier_name: record.supplier.try(:name),
        po_type: record.po_request.present? ? record.po_request.supplier_po_type : '-',
        comments: record.comments.present? ? record.comments.order(created_at: :desc).map.with_index { |mrq_comment, index| (index + 1).to_s + '. ' + mrq_comment.message + ' (' + mrq_comment.created_at.strftime('%d-%m-%Y %H:%M') + ')' }.join("\r\n") : '-',
        sales_order_date: (record.po_request.present? && record.po_request.sales_order.present?) ? format_succinct_date(record.po_request.sales_order.mis_date) : '-',
        sales_order: (record.po_request.present? && record.po_request.sales_order.present?) ? record.po_request.sales_order.order_number : '-',
        committed_date_to_customer: record.po_request.present? ? format_succinct_date(record.po_request.inquiry.customer_committed_date) : '-',
        inside_sales_owner: record.inquiry.inside_sales_owner.to_s,
        logistics_owner: (record.logistics_owner.present? ? record.logistics_owner.full_name : 'Unassigned'),
        material_follow_up_date: format_succinct_date(record.followup_date),
        expected_delivery_date: format_succinct_date(record.revised_supplier_delivery_date),
        payment_request_status: (record.payment_request.present? ? record.payment_request.status : 'Payment Request: Pending'),
        percentage_paid: record.payment_request.present? ? percentage(record.payment_request.percent_amount_paid, precision: 2) : '-',
        requested_date: format_succinct_date(record.email_sent_to_supplier_date),
        buying_price: record.po_request.present? ? record.po_request.buying_price : '-',
        selling_price: record.po_request.present? ? record.po_request.selling_price : '-',
        po_margin_percentage: record.po_request.present? ? record.po_request.po_margin_percentage : '-',
        calculated_total_margin_percentage: (record.po_request.present? && record.po_request.sales_order.present?) ? record.po_request.sales_order.calculated_total_margin_percentage : '-'
      )
    end

    # filtered = @ids.present?
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
