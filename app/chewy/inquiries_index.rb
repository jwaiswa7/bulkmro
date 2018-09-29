class InquiriesIndex < BaseIndex
  define_type Inquiry.all.with_includes do
    field :id
    field :status, analyzer: 'letter'
    field :calculated_total, value: -> (record) { record.final_sales_quote.calculated_total.to_i if record.final_sales_quote.present? }
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }, analyzer: 'letter'
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'letter'
    field :company, value: -> (record) { record.company.to_s }, analyzer: 'letter'
    field :account, value: -> (record) { record.account.to_s }, analyzer: 'letter'
    field :contact, value: -> (record) { record.contact.to_s }, analyzer: 'letter'
    field :created_at
    field :updated_at
    field :created_by, value: -> (record) { record.created_by.to_s }, analyzer: 'letter'
    field :updated_by, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
  end

end