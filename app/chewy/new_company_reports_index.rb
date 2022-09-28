class NewCompanyReportsIndex < BaseIndex
  statuses =  Inquiry.statuses.except('Lead by O/S', 'Order Lost', 'Regret').keys
  index_scope Inquiry.where.not(company_id: 1).where(status: statuses).with_includes 
    # default_import_options batch_size: 10000, bulk_size: 10.megabytes, refresh: false
    field :id, type: 'integer'
    field :live_inquiry, value: -> (record) { statuses.include?(record.status) ? 1 : 0 }, type: 'integer'
    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
    field :company_key, value: -> (record) { record.company.id }, type: 'integer'
    field :company_name, value: -> (record) { record.company.to_s }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.account.id }, type: 'integer'
    field :account_name, value: -> (record) { record.account.to_s }, analyzer: 'substring'
    field :expected_order, value: -> (record) {record.status == 'Expected Order' ? 1 : 0}, type: 'integer'
    field :expected_order_total, value: -> (record) {record.status == 'Expected Order' ? record.try(:calculated_total) : 0}, type: 'double'
    field :inside_sales_executive, value: -> (record) { record.inside_sales_owner_id }, type: 'integer'
    field :outside_sales_executive, value: -> (record) { record.outside_sales_owner_id }, type: 'integer'
    field :sales_manager, value: -> (record) { record.sales_manager_id }, type: 'integer'
    field :procurement_operations, value: -> (record) { record.procurement_operations_id }, type: 'integer'

    field :sales_quotes_count, value: -> (record) {(statuses.include?(record.status) && record.bible_final_sales_quotes.present?) ? record.bible_final_sales_quotes.count : 0}, type: 'integer'
    field :sales_quotes_total, value: -> (record) {(statuses.include?(record.status) && record.bible_final_sales_quotes.present?) ? record.bible_total_quote_value : 0}, type: 'double'
    field :sales_quotes_margin_percentage, value: -> (record) {(statuses.include?(record.status) && record.bible_final_sales_quotes.present?) ? record.bible_total_quote_margin_percentage : 0}, type: 'double'

    field :sales_orders_count, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_orders.present?) ? record.bible_sales_orders.count : 0}, type: 'integer'
    field :sales_orders_total, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_orders.present?) ? record.bible_sales_order_total : 0}, type: 'double'
    field :sales_orders_total_margin, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_orders.present?) ? record.bible_assumed_margin : 0}, type: 'double'
    field :sales_orders_overall_margin_percentage, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_orders.present?) ? record.bible_margin_percentage : 0}, type: 'double'

    # field :final_sales_orders, value: -> (record) { BibleSalesOrder.where(inquiry_number: record.inquiry_number)} do
    #   field :order_total, type: 'double'
    #   field :total_margin, type: 'double'
    #   field :overall_margin_percentage, type: 'double'
    # end
    #
    field :invoices_count, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_invoices.present?) ? record.bible_sales_invoices.count : 0}, type: 'integer'
    field :invoice_total, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_invoices.present?) ? record.bible_sales_invoice_total : 0}, type: 'double'
    field :invoices_total_margin, value: -> (record) {(statuses.include?(record.status) && record.bible_sales_invoices.present?) ? record.bible_actual_margin : 0}, type: 'integer'
    # field :invoices, value: -> (record) { BibleInvoice.where(inquiry_number: record.inquiry_number)} do
    #   field :invoice_total, type: 'double'
    # end

    field :cancelled_invoiced, value: -> (record) { record.invoices.where(status: 'Cancelled').count}, type: 'integer'
    field :cancelled_invoiced_total, value: -> (record) { record.invoices.where(status: 'Cancelled').map(&:calculated_total).compact.sum}, type: 'double'

    field :sku, value: -> (record) {record.unique_skus_in_order }, type: 'integer'
  
end