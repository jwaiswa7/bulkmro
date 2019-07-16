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
    field :material_dispatch_date, type: 'date'
    field :expected_date_of_delivery, type: 'date'
    field :material_delivery_date, type: 'date'
    field :material_delivery_date, type: 'date'
    field :logistics_owner_id, value: -> (record) { record.ar_invoice_request.inquiry.company.logistics_owner_id if record.ar_invoice_request.present? && record.ar_invoice_request.inquiry.present? && record.ar_invoice_request.inquiry.company.present? }, type: 'integer'
    field :logistics_owner, value: -> (record) { record.ar_invoice_request.inquiry.company.logistics_owner&.name if record.ar_invoice_request.present? && record.ar_invoice_request.inquiry.present? && record.ar_invoice_request.inquiry.company.present? }, analyzer: 'substring'
    field :is_owner_id, value: -> (record) { record.ar_invoice_request.inquiry.inside_sales_owner_id if record.ar_invoice_request.present? && record.ar_invoice_request.inquiry.present? }, type: 'integer'
    field :is_owner, value: -> (record) { record.ar_invoice_request.inquiry.inside_sales_owner&.name if record.ar_invoice_request.present? && record.ar_invoice_request.inquiry.present? }, analyzer: 'substring'
  end
end
