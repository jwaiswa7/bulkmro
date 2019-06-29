class ArInvoiceRequestsIndex < BaseIndex
  statuses = ArInvoiceRequest.statuses
  define_type ArInvoiceRequest.all do
    field :id
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :ar_invoice_number_string, value: -> (record) { record.ar_invoice_number.to_s}, analyzer: 'substring', fielddata: true
    field :ar_invoice_number, value: -> (record) { record.ar_invoice_number}, type: 'integer'
    field :sales_order_number_string, value: -> (record) { record.sales_order.order_number.to_s if record.sales_order.present? }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status]}
    field :status_string, value: -> (record) { record.status }
    field :created_by_id, value: -> (record) { record.created_by_id if record.created_by_id.present? }
    field :updated_by_id, value: -> (record) { record.updated_by_id if record.updated_by_id.present? }
    field :created_by_name, value: -> (record) { record.created_by.name if record.created_by_id.present? }, analyzer: 'substring'
    field :updated_by_name, value: -> (record) { record.updated_by.name if record.updated_by_id.present? }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
