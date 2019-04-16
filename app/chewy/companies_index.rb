class CompaniesIndex < BaseIndex
  businesses = Company.nature_of_businesses
  define_type Company.where('id<200').with_includes do
    field :id, type: 'integer'
    field :account_id, value: -> (record) {record.account_id}
    field :name, value: -> (record) {record.name}, analyzer: 'fuzzy_substring'
    field :account, value: -> (record) {record.account.to_s}, analyzer: 'substring', fielddata: true
    field :addresses, value: -> (record) {record.addresses.size}, type: 'integer'
    field :addresses_string, value: -> (record) {record.addresses.to_s}, analyzer: 'substring'
    field :contacts_string, value: ->(record) {record.default_contact&.name}
    field :contacts, value: -> (record) {record.contacts.size}, type: 'integer'
    field :inquiries, value: -> (record) {record.inquiries.size}, type: 'integer'
    field :pan, value: -> (record) {record.pan.to_s}, analyzer: 'substring'
    field :is_pan_valid, value: -> (record) {record.validate_pan}
    field :is_supplier, value: -> (record) {record.is_supplier?}
    field :is_customer, value: -> (record) {record.is_customer?}
    field :rating, value: -> (record) {record.rating}, type: 'float'
    field :sap_status, value: -> (record) {record.synced?}

    field :nature_of_business_string, value: -> (record) {record.nature_of_business}
    field :nature_of_business, value: -> (record) {businesses[record.nature_of_business]}
    field :purchase_orders_count, value: -> (record) {record.purchase_orders.count}, type: 'integer'
    field :supplied_brands_count, value: -> (record) {record.supplied_brands.uniq.count}, type: 'integer'
    field :supplied_products_count, value: -> (record) {record.supplied_products.uniq.count}, type: 'integer'
    field :supplied_brand_names, value: -> (record) {record.supplied_brands.map(&:name).uniq.join(',').upcase}

    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
    field :inquiries_size, value: -> (record) {record.inquiry_size}, type: 'integer'
    field :inquiries, value: -> (record) {record.inquiries.count}, type: 'integer'
    field :invoices_count, value: -> (record) {record.inquiries.map{|i| i.invoices.pluck(:id)}.flatten.compact.count}, type: 'integer'
    field :sales_quote_count, value: -> (record) {record.inquiries.map{|i| i.final_sales_quote}.flatten.compact.count}, type: 'integer'
    field :sales_order_count, value: -> (record) {record.inquiries.map{|i| i.final_sales_orders.pluck(:id)}.flatten.compact.count}, type: 'integer'
    field :expected_order, value: -> (record) {record.inquiries.where('inquiries.status = ?', 7).size}, type: 'integer'
    field :expected_value, value: -> (record) { record.inquiries.where('inquiries.status = ?', 7).map { |ip| ip.final_sales_quote.calculated_total if ip.final_sales_quote.present?}.compact.flatten.sum }, type: 'double'
    field :order_won, value: -> (record) {record.inquiries.where('inquiries.status = ?', 18).size}, type: 'integer'
    field :company_key, value: -> (record) { record.id }, type: 'integer'
    field :total_quote_value, value: -> (record) { record.inquiries.where.not('inquiries.status = ? OR inquiries.status = ?', 10,9).map { |ip| ip.final_sales_quote.calculated_total if ip.final_sales_quote.present?}.compact.flatten.sum }, type: 'double'
    field :total_order_value, value: -> (record) {record.inquiries.map{|i| i.final_sales_orders.map{|s| s.calculated_total}}.compact.flatten.sum}, type: 'double'
    field :total_margin, value: -> (record) { record.inquiries.map{|i| i.final_sales_orders.map{|s| s.calculated_total_margin}}.compact.flatten.sum }, type: 'double'
    field :margin_percentage, value: -> (record) { record.order_margin.sum.to_f / record.order_margin.count }, type: 'double'
    field :amount_invoiced, value: -> (record) { record.inquiries.map{|i| i.invoices.map{|s| s.calculated_total}}.compact.flatten.sum }, type: 'double'
    field :cancelled_invoiced, value: -> (record) { record.inquiries.map{|i| i.invoices.where(status: 'Cancelled').pluck(:id)}.flatten.compact.count }, type: 'integer'
    field :invoice_margin_percentage, value: -> (record) {record.invoice_margin.sum.to_f / record.invoice_margin.count }, type: 'double'
  end
end
