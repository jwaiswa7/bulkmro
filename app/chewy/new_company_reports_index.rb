class NewCompanyReportsIndex < BaseIndex
  statuses =  Inquiry.statuses.except('Order Lost', 'Regret').keys
  define_type Inquiry.all do
    # default_import_options batch_size: 10000, bulk_size: 10.megabytes, refresh: false
    field :id, type: 'integer'
    field :live_inquiry, value: -> (record) { statuses.include?(record.status) ? 1 : 0 }, type: 'integer'
    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
    field :company_key, value: -> (record) { record.company.id }, type: 'integer'
    field :expected_order, value: -> (record) {record.status == 'Expected Order' ? 1 : 0}, type: 'integer'
    field :expected_order_total, value: -> (record) {record.status == 'Expected Order' ? record.try(:calculated_total) : 0}, type: 'double'

    field :final_sales_quote, value: -> (record) {(statuses.include?(record.status) && record.final_sales_quote.present?) ? 1 : 0}, type: 'integer'
    field :final_sales_quote_total, value: -> (record) {(statuses.include?(record.status) && record.final_sales_quote.present?) ? record.final_sales_quote.try(:calculated_total) : 0}, type: 'double'
    field :final_sales_quote_margin_percentage, value: -> (record) {(statuses.include?(record.status) && record.final_sales_quote.present?) ? record.final_sales_quote.try(:calculated_total_margin_percentage) : 0}, type: 'double'

    field :final_sales_orders do
      field :calculated_total, type: 'double'
      field :calculated_total_margin, type: 'double'
      field :calculated_total_margin_percentage, type: 'double'
    end

    field :invoices do
      field :calculated_total, type: 'double'
    end

    field :cancelled_invoiced, value: -> (record) { record.invoices.where(status: 'Cancelled').count}, type: 'integer'
    field :cancelled_invoiced_total, value: -> (record) { record.invoices.where(status: 'Cancelled').map(&:calculated_total).compact.sum}, type: 'double'

    field :sku, value: -> (record) {record.final_sales_orders.uniq.map(&:products).flatten.uniq.count }, type: 'integer'
  end
end
