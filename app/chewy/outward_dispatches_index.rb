class OutwardDispatchesIndex < BaseIndex
  define_type OutwardDispatch.all do
    field :id
    field :inquiry_number_string, value: -> (record) { record.ar_invoice_request.inquiry.inquiry_number.to_s if record.ar_invoice_request.inquiry.present? }, analyzer: 'substring'
    field :sales_order_number_string, value: -> (record) { record.ar_invoice_request.sales_order.order_number.to_s if record.ar_invoice_request.sales_order.present? }, analyzer: 'substring'
    field :ar_invoice_request_no, value: -> (record) { record.ar_invoice_request.id.to_s if record.ar_invoice_request.present? }, analyzer: 'substring'
    field :created_at, type: 'date'
  end
end