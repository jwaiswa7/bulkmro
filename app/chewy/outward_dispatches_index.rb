class OutwardDispatchesIndex < BaseIndex
  statuses = OutwardDispatch.statuses
  define_type OutwardDispatch.all do
    field :id
    field :inquiry_number, value: -> (record) { record.ar_invoice_request.inquiry.inquiry_number if record.ar_invoice_request.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.ar_invoice_request.inquiry.inquiry_number.to_s if record.ar_invoice_request.inquiry.present? }, analyzer: 'substring'
    field :sales_order_number, value: -> (record) { record.ar_invoice_request.sales_order.order_number if record.ar_invoice_request.sales_order.present? }, type: 'long'
    field :sales_order_number_string, value: -> (record) { record.ar_invoice_request.sales_order.order_number.to_s if record.ar_invoice_request.sales_order.present? }, analyzer: 'substring'
    field :ar_invoice_request_number, value: -> (record) { record.ar_invoice_request.ar_invoice_number if record.ar_invoice_request.present? }, type: 'integer'
    field :ar_invoice_request_number_string, value: -> (record) { record.ar_invoice_request.ar_invoice_number.to_s if record.ar_invoice_request.present? }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }
    field :status_string, value: -> (record) { record.status.to_s }
    field :created_at, type: 'date'
  end
end
