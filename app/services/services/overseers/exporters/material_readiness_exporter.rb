class Services::Overseers::Exporters::MaterialReadinessExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = PurchaseOrder
    @export_name = 'material_readiness_queue'
    @path = Rails.root.join('tmp', filename)
    @columns = ['PO Request', 'Inquiry', 'Customer Company Name', 'Material Status', 'Supplier PO', 'Supplier PO Date', 'Supplier Name', 'PO Type', 'Latest Comment', 'Sales Order Date', 'Sales Order', 'Committed Date to Customer', 'IS&P', 'Logistics Owner', 'Material Follow Up Date', 'Expected Delivery Date', 'Payment Request status', 'Percentage Paid', 'Requested Date', 'Buying Price', 'Selling Price', 'PO Margin %', 'Overall Margin %']
  end

  def call
    perform_export_later('MaterialReadinessExporter', @arguments)
  end


  def build_csv
    model = PurchaseOrder
    records = model.all.where(material_status: ['Material Readiness Follow-Up', 'Inward Dispatch', 'Inward Dispatch: Partial', 'Material Partially Delivered']).joins(:po_request).where.not(po_requests: {id: nil}).where(po_requests: {status: 'Supplier PO Sent'})

    records.find_each(batch_size: 500) do |record|
      rows.push(
          po_request: record.po_request.present? ? record.po_request.id : '-',
          inquiry_number: record.inquiry.inquiry_number,
          company_name: record.inquiry.company.try(:name),
          material_status: record.material_status,
          supplier_po: record.po_number,
          supplier_po_date: (record.po_date ? format_succinct_date(record.po_date) : '-'),
          supplier_name: record.supplier.try(:name),
          po_type: record.po_request.present? ? record.po_request.supplier_po_type : '-',
          latest_comment: record.last_comment.present? ? record.last_comment : '-',
          sales_order_date: (record.po_request.present? && record.po_request.sales_order.present?) ? format_succinct_date(record.po_request.sales_order.mis_date) : '-',
          sales_order: (record.po_request.present? && record.po_request.sales_order.present?) ? record.po_request.sales_order.order_number : '-',
          committed_date_to_customer: record.po_request.present? ? format_succinct_date(record.po_request.inquiry.customer_committed_date) : '-',
          inside_sales_owner: record.inquiry.inside_sales_owner.to_s,
          logistics_owner: (record.logistics_owner.present? ? record.logistics_owner.full_name : 'Unassigned'),
          material_follow_up_date: format_succinct_date(record.followup_date),
          expected_delivery_date: format_succinct_date(record.revised_supplier_delivery_date),
          payment_request_status: (record.payment_request.present? ? record.payment_request.status : 'Payment Request: Pending'),
          percentage_paid: record.payment_request.present? ? percentage(record.payment_request.percent_amount_paid, precision: 2) : '-',
          requested_date:format_succinct_date(record.email_sent_to_supplier_date),
          buying_price: record.po_request.present? ? record.po_request.buying_price : '-',
          selling_price: record.po_request.present? ? record.po_request.selling_price : '-',
          po_margin_percentage: record.po_request.present? ? record.po_request.po_margin_percentage : '-',
          calculated_total_margin_percentage: (record.po_request.present? && record.po_request.sales_order.present?) ? record.po_request.sales_order.calculated_total_margin_percentage : '-'
      )
    end

    export = Export.create!(export_type: 96, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end



end