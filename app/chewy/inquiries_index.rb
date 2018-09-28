class InquiriesIndex < Chewy::Index
  define_type Inquiry.all.with_includes do
    field :id
    field :status
    field :calculated_total, value: -> (record) { record.final_sales_quote.calculated_total.to_i if record.final_sales_quote.present? }
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }
    field :company, value: -> (record) { record.company.to_s }
    field :account, value: -> (record) { record.account.to_s }
    field :contact, value: -> (record) { record.contact.to_s }
    field :created_at
    field :updated_at
    field :created_by, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

  def self.fields
    mappings_hash[:mappings][:inquiry][:properties].keys
  end
end