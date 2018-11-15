class SalesOrdersIndex < BaseIndex
  statuses = SalesOrder.statuses
  legacy_request_statuses = SalesOrder.legacy_request_statuses
  remote_statuses = SalesOrder.remote_statuses

  define_type SalesOrder.all.with_includes do
    field :id, type: 'integer'
    field :order_number, value: -> (record) {record.order_number.to_s}, analyzer: 'substring'
    field :inquiry_number, value: -> (record) {record.inquiry.inquiry_number.to_i}, type: 'integer'
    field :inquiry_number_string, value: -> (record) {record.inquiry.inquiry_number.to_s}, analyzer: 'substring'
    field :status_string, value: -> (record) {record.status.to_s}, analyzer: 'substring'
    field :status, value: -> (record) {statuses[record.status]}
    field :legacy_request_status, value: -> (record) {legacy_request_statuses[record.legacy_request_status]}
    field :approval_status, value: -> (record) {record.approved? ? 'approved' : 'pending'}
    field :legacy_status, value: -> (record) {record.legacy? ? 'legacy' : 'not_legacy'}
    field :remote_status_string, value: -> (record) {record.remote_status.to_s}, analyzer: 'substring'
    field :remote_status, value: -> (record) {remote_statuses[record.remote_status]}
    field :quote_total, value: -> (record) {record.sales_quote.calculated_total.to_i if record.sales_quote.calculated_total.present?}
    field :order_total, value: -> (record) {record.calculated_total.to_i if record.calculated_total.present?}
    field :customer_po_number, value: -> (record) {record.inquiry.customer_po_number}
    field :customer_po_number_string, value: -> (record) {record.inquiry.customer_po_number.to_s}, analyzer: 'substring'
    field :contact_id, value: -> (record) { record.inquiry.contact_id }, type: 'integer'
    field :company_id, value: -> (record) { record.inquiry.company.id }, type: 'integer'
    field :account_id, value: -> (record) { record.inquiry.contact.account.id }, type: 'integer'
    field :company, value: -> (record) {record.inquiry.company.to_s}, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) {record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present?}
    field :inside_sales_owner, value: -> (record) {record.inquiry.inside_sales_owner.to_s}, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) {record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present?}
    field :outside_sales_owner, value: -> (record) {record.inquiry.outside_sales_owner.to_s}, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) {record.inquiry.inside_sales_owner_id}
    field :outside_sales_executive, value: -> (record) {record.inquiry.outside_sales_owner_id}
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :sent_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) {record.updated_by.to_s}, analyzer: 'substring'
  end

end