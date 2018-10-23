class SalesInvoicesIndex < BaseIndex
  statuses = SalesInvoice.statuses
  define_type SalesInvoice.all.with_includes do
    field :id

    field :sales_order_id, value: -> (record) { record.sales_order.id if record.sales_order.present? }
    field :sales_order_string, value: -> (record) { record.sales_order.to_s }, analyzer: 'substring'
    field :invoice_number, value: -> (record) { record.invoice_number.to_i }, type: 'integer'
    field :status, value: -> (record) { statuses[record.status] }
    field :inside_sales_owner_id, value: -> (record) { record.sales_order.inquiry.inside_sales_owner.id if record.sales_order.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.sales_order.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.sales_order.inquiry.outside_sales_owner.id if record.sales_order.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.sales_order.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.sales_order.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.sales_order.inquiry.outside_sales_owner_id }

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end
end