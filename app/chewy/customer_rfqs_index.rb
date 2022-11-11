class CustomerRfqsIndex < BaseIndex
  define_type CustomerRfq.all do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: 'integer'
    field :account_id, value: -> (record) { record.account_id }, type: 'integer'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }, type: 'integer'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'  
    field :company_name, value:->(record) {record.inquiry.company.to_s}, analyzer: 'substring'
    field :company_contact, value:->(record) {record.inquiry.contact.to_s}, analyzer: 'substring'
  end
end
