class CompanyReportsIndex < BaseIndex
  define_type Company.with_includes do
    default_import_options batch_size: 100, bulk_size: 10.megabytes, refresh: false
    field :id, type: 'integer'
    field :account_id, value: -> (record) {record.account_id}, type: 'integer'
    field :name, value: -> (record) {record.name}, analyzer: 'fuzzy_substring'
    field :account, value: -> (record) {record.account.to_s}, analyzer: 'substring', fielddata: true

    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
    field :inquiries_size, value: -> (record) {record.inquiry_size}, type: 'integer'
    field :inquiries, value: -> (record) {record.inquiries.count}, type: 'integer'
    field :invoices_count, value: -> (record) {record.invoices.count}, type: 'integer'
    field :sales_quote_count, value: -> (record) {record.final_sales_quotes.count}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.sales_orders.count}, type: 'integer'
    field :order_won, value: -> (record) {record.inquiries.where('inquiries.status = ?', 18).size}, type: 'integer'
    field :company_key, value: -> (record) { record.id }, type: 'integer'

    field :expected_order, value: -> (record) {record.final_sales_quotes.where('inquiries.status = ?', 7)} do
      field :calculated_total, type: 'double'
    end
    field :final_sales_quotes, value: -> (record) { record.final_sales_quotes.where.not('inquiries.status = ? OR inquiries.status = ?', 10,9)} do
      field :calculated_total, type: 'double'
      field :calculated_total_margin_percentage, type: 'double'
    end
    field :final_sales_orders do
      field :calculated_total, type: 'double'
      field :calculated_total_margin, type: 'double'
      field :calculated_total_margin_percentage, type: 'double'
    end
    field :invoices do
      field :calculated_total, type: 'double'
    end

    field :cancelled_invoiced, value: -> (record) { record.invoices.where(status: 'Cancelled')} do
      field :calculated_total, type: 'double'
    end

    field :sku, value: -> (record) {record.final_sales_orders.uniq.map(&:products).flatten.uniq.count }, type: 'integer'
  end
end
