class Services::Overseers::Exporters::CustomerOrderStatusReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = SalesOrder
    @export_name = 'Customer Order Status Report'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry', 'Company', 'Sales Order', 'Sales Order Date', 'Committed Customer Delivery Date', 'Supplier PO No.', 'Supplier Name', 'PO Request Date', 'PO Date', 'PO Sent to Supplier Date', 'Payment Request Date', 'Payment Date', 'Committed Date of Material Readiness', 'Actual Date of Material Readiness', 'Date of Pickup', 'Date of Inward', 'Date of Outward', 'Date of Customer Delivery', 'On Time / Delayed (viz. customer committed date)']
  end

  def call
    perform_export_later('CustomerOrderStatusReportsExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |sales_order|
      rows.push(
        inquiry_number: sales_order[:inquiry_number],
        company: sales_order[:company],
        order_number: sales_order[:order_number].present? ? sales_order[:order_number] : '-',
        mis_date: sales_order[:mis_date].present? ? format_date_without_time(Date.parse(sales_order[:mis_date])) : '-',
        cp_committed_date: sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
        po_number: sales_order[:po_number].present? ? sales_order[:po_number] : '-',
        supplier_name: sales_order[:supplier_name].present? ? sales_order[:supplier_name] : '-',
        supplier_po_request_date: sales_order[:supplier_po_request_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_request_date])) : '-',
        supplier_po_date: sales_order[:supplier_po_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_date])) : '-',
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
    export = Export.create!(export_type: 92, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
