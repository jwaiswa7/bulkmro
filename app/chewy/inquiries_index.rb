  class InquiriesIndex < BaseIndex
    statuses = Inquiry.statuses.except('Lead by O/S')
    pipeline_statuses = Inquiry.statuses.except('Lead by O/S', 'Supplier RFQ Sent', 'SO Not Created-Customer PO Awaited', 'Hold by Accounts')

    define_type Inquiry.all.with_includes do
      field :id, type: 'integer'
      field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
      field :status, value: -> (record) { statuses[record.status] }
      field :status_key, value: -> (record) { statuses[record.status] }, type: 'integer'
      field :pipeline_status_key, value: -> (record) { pipeline_statuses[record.status] }, type: 'integer'
      field :subject, analyzer: 'substring'
      field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
      field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
      # field :sales_orders_ids, value: -> (record) { record.sales_orders.where.not(order_number: nil).map(&:order_number).compact.join(',') if record.sales_orders.ids.present? }, analyzer: 'substring'
      # field :sales_invoices_ids, value: -> (record) { record.invoices.map(&:invoice_number).compact.join(',') if record.invoices.ids.present? }, analyzer: 'substring'
      field :potential_amount, value: -> (record) { record.potential_amount.to_f if record.potential_amount.present? }, type: 'integer'
      field :calculated_total, value: -> (record) { record.calculated_total.to_i if record.calculated_total.present? }, type: 'integer'
      field :inside_sales_owner_id, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? }, type: 'integer'
      field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }, analyzer: 'substring'
      field :outside_sales_owner_id, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? }
      field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'substring'
      field :procurement_operations_id, value: -> (record) { record.procurement_operations.id if record.procurement_operations.present? }
      field :procurement_operations, value: -> (record) { record.procurement_operations.to_s }, analyzer: 'substring'
      field :inside_sales_executive, value: -> (record) { record.inside_sales_owner_id }
      field :outside_sales_executive, value: -> (record) { record.outside_sales_owner_id }
      field :procurement_operations, value: -> (record) { record.procurement_operations_id }
      field :margin_percentage, value: -> (record) { record.margin_percentage }, type: 'float'
      field :company_id, value: -> (record) { record.company_id }
      field :company, value: -> (record) { record.company.to_s }, analyzer: 'substring'
      field :account_id, value: -> (record) { record.account_id }
      field :account, value: -> (record) { record.account.to_s }, analyzer: 'substring'
      field :contact_id, value: -> (record) {record.contact_id}
      field :contact_s, value: -> (record) { record.contact.to_s }, analyzer: 'substring'
      field :priority, type: 'integer'
      field :quotation_followup_date, type: 'date'
      field :customer_committed_date, type: 'date'
      field :created_at, type: 'date'
      field :updated_at, type: 'date'
      field :created_by_id
      field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
      field :potential_value, value: -> (record) { record.potential_value(record.status.to_s) }, type: 'double'
      # field :sales_quote_value, value: -> (record) { record.final_sales_quote.calculated_total if record.final_sales_quote.present? }, type: 'double'
      # field :sales_quote_created_at, value: -> (record) {record.final_sales_quote.created_at if record.final_sales_quote.present? }, type: 'date'
    end

    def self.fields
      [:status, :status_string, :subject, :inquiry_number_string, :sales_orders_ids, :sales_invoices_ids, :inside_sales_owner, :outside_sales_owner, :inside_sales_executive, :outside_sales_executive, :procurement_operations, :company, :account, :contact_s, :created_by_id]
    end
  end
