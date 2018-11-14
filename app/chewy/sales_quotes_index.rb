class SalesQuotesIndex < BaseIndex
  statuses = Inquiry.statuses
  define_type SalesQuote.all.with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) {record.inquiry.inquiry_number.to_i}, type: 'integer'
    field :inquiry_number_string, value: -> (record) {record.inquiry.inquiry_number.to_s}, analyzer: 'substring'
    field :line_items, value: -> (record) {record.rows.size.to_s}, analyzer: 'substring'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :valid_upto_s, value: -> (record) {record.inquiry.valid_end_time.to_s}, analyzer: 'substring'
    field :status_string, value: -> (record) { record.inquiry.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.inquiry.status] }
    field :quote_total, value: -> (record) {record.calculated_total.to_i if record.calculated_total.present?}
    field :quote_total_string, value: -> (record) {record.calculated_total.to_s if record.calculated_total.present?}, analyzer: 'substring'
    field :contact_id, value: -> (record) { record.inquiry.contact_id }, type: 'integer'
    field :company_id, value: -> (record) { record.inquiry.company.id }, type: 'integer'
    field :account_id, value: -> (record) { record.inquiry.account.id }, type: 'integer'
    field :created_at, type: 'date'
  end
  
end