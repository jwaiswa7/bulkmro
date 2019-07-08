class KraReportsIndex < BaseIndex
  start_date = '01-04-2019'
  end_date = '06-07-2019'
  define_type Inquiry.where(created_at: start_date..end_date).with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? && record.inside_sales_owner.role == 'inside_sales_executive' }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s if record.inside_sales_owner.present? && record.inside_sales_owner.role == 'inside_sales_executive' }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? && record.outside_sales_owner.role == 'outside_sales_executive' }, type: 'integer'
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s  if record.outside_sales_owner.present? && record.outside_sales_owner.role == 'outside_sales_executive' }, analyzer: 'substring'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
    field :inside_sales_executive, value: -> (record) { record.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.outside_sales_owner_id }
    field :margin_percentage, value: -> (record) { record.margin_percentage }, type: 'float'
    field :procurement_operations, value: -> (record) { record.procurement_operations_id }
    field :invoices_count, value: -> (record) {record.invoices.count}, type: 'integer'
    field :sales_quote_count, value: -> (record) {record.final_sales_quote.present? ? 1 : 0}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.final_sales_orders.without_cancelled.count}, type: 'integer'
    field :expected_order, value: -> (record) {record.status == 'Expected Order' ? 1 : 0}, type: 'integer'
    field :order_won, value: -> (record) {record.status == 'Order Won' ? 1 : 0}, type: 'integer'
    field :company_key, value: -> (record) { record.company_id }, type: 'integer'
    field :account_key, value: -> (record) { record.company.account_id }, type: 'integer'
    field :total_quote_value, value: -> (record) {record.final_sales_quote.calculated_total if record.final_sales_quote.present?}, type: 'double'
    field :total_order_value, value: -> (record) {record.final_sales_orders.without_cancelled.compact.uniq.map(&:calculated_total).sum}, type: 'double'
    field :revenue, value: -> (record) {record.final_sales_orders.without_cancelled.compact.uniq.map(&:calculated_total_margin).sum}, type: 'double'
    field :sku, value: -> (record) {record.final_sales_orders.without_cancelled.compact.uniq.map {|s|s.products.map(&:sku).count}.last}, type: 'integer'
    field :gross_margin_assumed, value: -> (record) { record.final_sales_quote.calculated_total_margin if record.final_sales_quote.present? }, type: 'double'
    field :gross_margin_percentage, value: -> (record) { record.margin_percentage }, type: 'double'
    field :gross_margin_actual, value: -> (record) { record.final_sales_orders.without_cancelled.compact.uniq.map(&:calculated_total_margin).sum if record.final_sales_orders.present? }, type: 'double'
  end
end
