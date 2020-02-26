class Services::Overseers::Exporters::CustomerOrderStatusReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = SalesOrder
    @export_name = 'Customer Order Status Report'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry', 'Company', 'Sales Order', 'Sales Order Date', 'Sales Order Created Date', 'Invoice Number', 'SKU', 'Total Selling Price', 'Customer Order Date', 'Customer PO Delivery Date', 'Customer PO Received Date', 'Committed Customer Delivery Date', 'Revised Customer Delivery Date', 'Supplier PO No.', 'Supplier Name', 'PO Request Date', 'PO Date', 'Lead Date', 'PO Sent to Supplier Date', 'Payment Request Date', 'Payment Date', 'Committed Date of Material Readiness', 'Actual Date of Material Readiness', 'Date of Pickup', 'Date of Inward', 'Date of Outward', 'Date of Customer Delivery', 'On Time / Delayed (viz. customer committed date)']
  end

  def call
    perform_export_later('CustomerOrderStatusReportsExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    if @indexed_records.present?
      records = @indexed_records
    else
      service = Services::Overseers::Finders::CustomerOrderStatusReports.new({}, @overseer, paginate: false)
      service.call
      records = service.indexed_records
      sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(records, 'All').fetch_data_bm_wise
    end

    @export = Export.create!(export_type: 92, status: 'Processing', filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.each do |sales_order|
      rows.push(
        inquiry_number: sales_order[:inquiry_number],
        company: sales_order[:company],
        order_number: sales_order[:order_number].present? ? sales_order[:order_number] : '-',
        mis_date: sales_order[:mis_date].present? ? format_date_without_time(Date.parse(sales_order[:mis_date])) : '-',
        created_at: sales_order[:created_at].present? ? format_date_without_time(Date.parse(sales_order[:created_at])) : '-',
        invoice_number: sales_order.present? ? sales_order[:invoice_number] : '',
        sku: sales_order[:sku].present? ? sales_order[:sku] : '',
        total_selling_price: sales_order[:total_selling_price].present? ? sales_order[:total_selling_price] : '',
        customer_order_date: sales_order[:customer_order_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_order_date])) : '-',
        customer_po_delivery_date: sales_order[:customer_po_delivery_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_po_delivery_date])) : '-',
        customer_po_received_date: sales_order[:customer_po_received_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_po_received_date])) : '-',
        cp_committed_date: sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
        revised_committed_delivery_date: sales_order[:revised_committed_delivery_date].present? ? format_date_without_time(Date.parse(sales_order[:revised_committed_delivery_date])) : '-',
        po_number: sales_order[:po_number].present? ? sales_order[:po_number] : '-',
        supplier_name: sales_order[:supplier_name].present? ? sales_order[:supplier_name] : '-',
        supplier_po_request_date: sales_order[:supplier_po_request_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_request_date])) : '-',
        supplier_po_date: sales_order[:supplier_po_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_date])) : '-',
        lead_time: sales_order[:lead_time].present? ? format_date_without_time(Date.parse(sales_order[:lead_time])) : '-',
        po_email_sent: sales_order[:po_email_sent].present? ? format_date_without_time(Date.parse(sales_order[:po_email_sent])) : '-',
        payment_request_date: sales_order[:payment_request_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_request_date])) : '-',
        payment_date: sales_order[:payment_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_date])) : '-',
        committed_material_readiness_date: sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
        actual_material_readiness_date: sales_order[:actual_material_readiness_date].present? ? format_date_without_time(Date.parse(sales_order[:actual_material_readiness_date])) : '-',
        pickup_date: sales_order[:pickup_date].present? ? format_date_without_time(Date.parse(sales_order[:pickup_date])) : '-',
        inward_date: sales_order[:inward_date].present? ? format_date_without_time(Date.parse(sales_order[:inward_date])) : '-',
        outward_date: sales_order[:outward_date].present? ? format_date_without_time(Date.parse(sales_order[:outward_date])) : '-',
        customer_delivery_date: sales_order[:customer_delivery_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_delivery_date])) : '-',
        on_time_or_delayed_time: sales_order[:on_time_or_delayed_time].present? ? humanize(sales_order[:on_time_or_delayed_time]) : '-'
      )
    end
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
