class SalesInvoicesIndex < BaseIndex
  statuses = SalesInvoice.statuses

  define_type SalesInvoice.all.with_includes do
    field :id

    field :sales_order_id, value: -> (record) {record.sales_order.id if record.sales_order.present?}
    field :sales_order_number, value: -> (record) {record.sales_order.order_number.to_i if record.sales_order.present?}, type: 'integer'
    field :invoice_number, value: -> (record) {record.invoice_number.to_i}, type: 'integer'
    field :inquiry_number, value: -> (record) {record.inquiry.inquiry_number.to_i if record.inquiry.present?}, type: 'integer'
    field :status, value: -> (record) {statuses[record.status]}
    field :inside_sales_owner_id, value: -> (record) {record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present?}
    field :inside_sales_owner, value: -> (record) {record.inquiry.inside_sales_owner.to_s if record.inquiry.present?}, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) {record.inquiry.outside_sales_owner.id if record.inquiry.present? && record.inquiry.outside_sales_owner.present?}
    field :outside_sales_owner, value: -> (record) {record.inquiry.outside_sales_owner.to_s if record.inquiry.present?}, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) {record.inquiry.inside_sales_owner_id if record.inquiry.present?}
    field :outside_sales_executive, value: -> (record) {record.inquiry.outside_sales_owner_id if record.inquiry.present?}

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end