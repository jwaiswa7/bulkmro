class CompanyReportsIndex < BaseIndex
  define_type Company.all do
    witchcraft!
    field :id, type: 'integer'
    field :account_id, value: -> (record) {record.account_id}
    field :name, value: -> (record) {record.name}, analyzer: 'fuzzy_substring'
    field :account, value: -> (record) {record.account.to_s}, analyzer: 'substring', fielddata: true

    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
    field :inquiries_size, value: -> (record) {record.inquiry_size}, type: 'integer'
    field :inquiries, value: -> (record) {record.inquiries.count}, type: 'integer'
    field :invoices_count, value: -> (record) {record.invoices.pluck(:id).flatten.compact.count}, type: 'integer'
    field :sales_quote_count, value: -> (record) {record.final_sales_quotes.count}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.sales_orders.count}, type: 'integer'
    field :expected_order, value: -> (record) {record.inquiries.where('inquiries.status = ?', 7).size}, type: 'integer'
    field :expected_value, value: -> (record) { record.final_sales_quotes.joins(:inquiry).where('inquiries.status = ?',7).map(&:calculated_total).compact.flatten.sum }, type: 'double'
    field :order_won, value: -> (record) {record.inquiries.where('inquiries.status = ?', 18).size}, type: 'integer'
    field :company_key, value: -> (record) { record.id }, type: 'integer'

    field :final_sales_quotes, value: -> (record) { record.final_sales_quotes.joins(:inquiry).where.not('inquiries.status = ? OR inquiries.status = ?', 10,9)} do
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

    field :cancelled_invoiced, value: -> (record) { record.invoices.where(status: 'Cancelled').compact.count }, type: 'integer'
  end
end
