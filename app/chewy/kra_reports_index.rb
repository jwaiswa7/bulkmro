class KraReportsIndex < BaseIndex
  define_type Inquiry.all.with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) {record.inquiry_number.to_i}, type: 'integer'
    field :inquiry_number_string, value: -> (record) {record.inquiry_number.to_s}, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) {record.inside_sales_owner.id if record.inside_sales_owner.present? && record.inside_sales_owner.role == 'inside_sales_executive'}, type: 'integer'
    field :inside_sales_owner, value: -> (record) {record.inside_sales_owner.to_s if record.inside_sales_owner.present? && record.inside_sales_owner.role == 'inside_sales_executive'}, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) {record.outside_sales_owner.id if record.outside_sales_owner.present? && record.outside_sales_owner.role == 'outside_sales_executive'}, type: 'integer'
    field :outside_sales_owner, value: -> (record) {record.outside_sales_owner.to_s if record.outside_sales_owner.present? && record.outside_sales_owner.role == 'outside_sales_executive'}, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) {record.updated_by.to_s}, analyzer: 'letter'
    field :inside_sales_executive, value: -> (record) {record.bible_inside_sales_owner}
    field :outside_sales_executive, value: -> (record) {record.bible_outside_sales_owner}
    field :procurement_operations, value: -> (record) {record.procurement_operations_id.present? ? record.procurement_operations_id : record.inside_sales_owner_id}
    field :sales_quote_count, value: -> (record) {record.bible_final_sales_quotes ? record.bible_final_sales_quotes.count : 0}, type: 'integer'
    field :expected_order, value: -> (record) {record.status == 'Expected Order' ? 1 : 0}, type: 'integer'
    field :order_won, value: -> (record) {record.status == 'Order Won' ? 1 : 0}, type: 'integer'
    field :company_key, value: -> (record) {record.company_id}, type: 'integer'
    field :account_key, value: -> (record) {record.company.account_id}, type: 'integer'
    field :total_quote_value, value: -> (record) {record.total_quote_value if record.has_final_sales_quote?}, type: 'double'

    # field :sku, value: -> (record) {record.unique_skus_in_order.count}, type: 'integer'
    field :sku, value: -> (record) {record.unique_skus_in_order}, type: 'integer'
    field :invoices_count, value: -> (record) {record.bible_sales_invoices.count}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.bible_sales_orders.count}, type: 'integer'
    field :margin_percentage, value: -> (record) {record.bible_margin_percentage}, type: 'float'
    field :total_order_value, value: -> (record) {record.bible_sales_order_total}, type: 'double'
    field :revenue, value: -> (record) {record.bible_revenue}, type: 'double'
  end
end