class ContactsIndex < BaseIndex
  index_scope Contact.all 
    field :id, type: 'integer'
    field :company_id, value: -> (record) {record.company.id if record.company.present?}
    field :account_id, value: -> (record) {record.account.id if record.account.present?}
    field :firstname, value: -> (record) { record.first_name.to_s }, analyzer: 'substring'
    field :lastname, value: -> (record) { record.last_name.to_s }, analyzer: 'substring'
    field :email, value: -> (record) { record.email.to_s }, analyzer: 'substring'
    field :account, value: -> (record) { record.account.name.to_s }, analyzer: 'substring'
    field :inquiry, value: -> (record) { record.inquiries.count }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  
end
