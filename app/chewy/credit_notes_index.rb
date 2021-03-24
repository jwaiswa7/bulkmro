class CreditNotesIndex < BaseIndex
  statuses = SalesInvoice.statuses

  define_type CreditNote.all.with_includes do
    field :id, type: 'integer'
    field :memo_number, value: -> (record) { record.memo_number.to_i }, type: 'integer'
    field :memo_amount, value: -> (record) { record.memo_amount.to_f }, type: 'float'
    field :memo_date, value: -> (record) { record.memo_date.to_date }, type: 'date'
    field :memo_number_string, value: -> (record) { record.memo_number.to_s }, analyzer: 'substring'
    field :invoice_number, value: -> (record) { record.sales_invoice.invoice_number.to_i }, type: 'integer'
    field :invoice_number_string, value: -> (record) { record.sales_invoice.invoice_number.to_s }, analyzer: 'substring'
    field :invoice_date, value: -> (record) { record.sales_invoice.mis_date }, type: 'date'
    field :invoice_amount, value: -> (record) { record.sales_invoice.metadata['base_grand_total'] }, type: 'float'
    field :inquiry, value: -> (record) { record.sales_invoice.inquiry.inquiry_number }, type: 'integer'
    field :account_id, value: -> (record) { record.sales_invoice.inquiry.company.account_id if record.sales_invoice.inquiry.present? }, type: 'integer'
    field :account_string, value: -> (record) { record.sales_invoice.inquiry.company.account.to_s if record.sales_invoice.inquiry.present? }, analyzer: 'substring'
    field :sales_order_number_string, value: -> (record) { record.sales_invoice.sales_order.order_number.to_s if record.sales_invoice.sales_order.present? }, analyzer: 'substring'
    field :sales_order_number, value: -> (record) { record.sales_invoice.sales_order.order_number.to_i if record.sales_invoice.sales_order.present? }, type: 'long'
    field :company_id, value: -> (record) { record.sales_invoice.inquiry.company_id if record.sales_invoice.inquiry.present? }, type: 'integer'
    field :company_string, value: -> (record) { record.sales_invoice.inquiry.company.to_s if record.sales_invoice.inquiry.present? }, analyzer: 'substring'
    field :sales_invoice_present, value: -> (record) { record.sales_invoice.present? }, type: 'boolean'
    field :status, value: -> (record) { statuses[record.sales_invoice.status] }, analyzer: 'substring'
    field :status_key, value: -> (record) { statuses[record.sales_invoice.status] }, type: 'integer'
    field :status_string, value: -> (record) { record.sales_invoice.status.to_s }, analyzer: 'substring'
    field :inquiry_number_string, value: -> (record) { record.sales_invoice.inquiry.inquiry_number.to_s if record.sales_invoice.inquiry.present? }, analyzer: 'substring'
    field :created_at, value: ->(record) { record.created_at.to_date if record.created_at.present? }, type: 'date'
    field :updated_at, type: 'date'
  end
end
