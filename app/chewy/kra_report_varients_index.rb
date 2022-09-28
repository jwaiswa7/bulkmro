class KraReportVarientsIndex < BaseIndex
  index_scope SalesOrder.without_cancelled.where.not(sent_at: nil) 
    default_import_options batch_size: 1000, bulk_size: 10.megabytes, refresh: false
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? }, type: 'integer'
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? && record.inside_sales_owner.role == 'inside_sales_executive' }
    field :outside_sales_executive, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? && record.outside_sales_owner.role == 'outside_sales_executive' }
    field :company_key, value: -> (record) { record.company_id }, type: 'integer'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
    field :expected_order, value: -> () { 0 }, type: 'integer'
    field :order_won, value: -> (record) { record.inquiry.status == 'Order Won' ? 1 : 0 }, type: 'integer'
    field :sku, value: -> (record) { record.unique_skus_in_order }, type: 'integer'

    field :sales_order_count, value: -> () { 0 }, type: 'integer'
    field :invoices_count, value: -> (record) { record.bible_sales_invoices.count }, type: 'integer'
    field :total_quote_value, value: -> (record) { record.bible_total_quote_value }, type: 'double'
    field :total_order_value, value: -> (record) { record.bible_sales_order_total }, type: 'double'

    field :revenue, value: -> (record) { record.bible_sales_invoice_total }, type: 'double'
    field :gross_margin_assumed, value: -> (record) { record.bible_assumed_margin }, type: 'double'
    field :gross_margin_percentage, value: -> (record) { record.bible_margin_percentage }, type: 'double'
    field :gross_margin_actual, value: -> (record) { record.bible_actual_margin }, type: 'double'
    field :gross_margin_actual_percentage, value: -> (record) { record.bible_actual_margin_percentage }, type: 'double'

end
