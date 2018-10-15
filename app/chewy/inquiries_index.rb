class InquiriesIndex < BaseIndex
  define_type Inquiry.all.with_includes do
    field :id, type: 'integer'
    field :status, analyzer: 'substring'
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :calculated_total, value: -> (record) { record.final_sales_quote.calculated_total.to_i if record.final_sales_quote.present? }
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'substring'
    field :company, value: -> (record) { record.company.to_s }, analyzer: 'substring'
    field :account, value: -> (record) { record.account.to_s }, analyzer: 'substring'
    field :contact, value: -> (record) { record.contact.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
  end

  def self.fields
    [:status, :inquiry_number_string, :inside_sales_owner, :outside_sales_owner, :company, :account, :contact, :created_by_id]
  end
end