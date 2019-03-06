class SalesReceiptsIndex < BaseIndex
  payment_types = SalesReceipt.payment_types
  payment_methods = SalesReceipt.payment_methods
  define_type SalesReceipt.all.with_includes do
    field :id, type: 'integer'
    field :company_id, value: -> (record) { record.company_id if record.company_id.present? }
    field :account_id, value: -> (record) { record.company.account.id if record.company_id.present? }
    field :company_alias, value: -> (record) { record.company.account.alias if record.company_id.present? }
    field :invoice_id, value: -> (record) { record.sales_invoice_id if record.sales_invoice_id.present? }
    field :invoice_number, value: -> (record) { record.sales_invoice.invoice_number if record.sales_invoice_id.present? }, type: 'integer'
    field :invoice_number_string, value: -> (record) { record.sales_invoice.invoice_number.to_s if record.sales_invoice_id.present? }, analyzer: 'substring'
    field :invoice_date, value: -> (record) { record.sales_invoice.created_at if record.sales_invoice_id.present? }, type: 'date'
    field :receipt_date, value: -> (record) { record.payment_received_date if record.payment_received_date.present? }, type: 'date'
    field :company, value: -> (record) { record.company.to_s if record.company_id.present? }, analyzer: 'substring'
    field :created_by_id, value: -> (record) { record.created_by_id if record.created_by_id.present? }
    field :created_by_name, value: -> (record) { record.created_by.name if record.created_by_id.present? }, analyzer: 'substring'
    field :payment_type, value: -> (record) { payment_types[record.payment_type.downcase] if record.payment_type.present? }
    field :payment_type_string, value: -> (record) { record.payment_type.to_s }, analyzer: 'substring'
    field :payment_method, value: -> (record) { payment_methods[record.payment_method.downcase] if record.payment_method.present? }
    field :payment_method_string, value: -> (record) { record.payment_method.to_s }, analyzer: 'substring'
    field :payment_received_amount, value: -> (record) { record.payment_amount_received if record.payment_amount_received.present? }, type: 'float'
    field :reference_number, value: -> (record) { record.remote_reference if record.remote_reference.present? }, analyzer: 'substring'
    field :currency_id, value: -> (record) { record.currency_id if record.currency_id.present? }
    field :currency_name, value: -> (record) { record.currency.name if record.currency_id.present? }
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end

  def self.fields
    [:invoice_number_string, :reference_number, :company_alias, :company, :payment_type_string, :payment_method_string, :currency_name]
  end
end
