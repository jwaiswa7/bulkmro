class KraReportsIndex < BaseIndex
  define_type Inquiry.all.with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? }, type: 'integer'
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'substring'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
    field :inside_sales_executive, value: -> (record) { record.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.outside_sales_owner_id }
    field :procurement_operations, value: -> (record) { record.procurement_operations_id }
    field :invoices_count, value: -> (record) {record.invoices.count}, type: 'integer'
    field :sales_quote_count, value: -> (record) {record.final_sales_quote.present? ? 1 : 0}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.final_sales_orders.count}, type: 'integer'
    field :expected_order, value: -> (record) {record.status == 'Expected Order' ? 1 : 0}, type: 'integer'
    field :order_won, value: -> (record) {record.status == 'Order Won' ? 1 : 0}, type: 'integer'
    field :company_key, value: -> (record) { record.company_id }, type: 'integer'
    field :total_quote_value, value: -> (record) {record.final_sales_quote.calculated_total if record.final_sales_quote.present?}, type: 'double'
    field :total_order_value, value: -> (record) {record.final_sales_orders.compact.uniq.map(&:calculated_total).sum}, type: 'double'
    field :revenue, value: -> (record) {record.final_sales_orders.compact.uniq.map(&:calculated_total_margin).sum}, type: 'double'
    field :sku, value: -> (record) {record.final_sales_orders.compact.uniq.map {|s|s.products.map(&:sku).count}.last}, type: 'integer'
  end
end
