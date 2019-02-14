

class ContactsIndex < BaseIndex
  define_type Contact.all do
    field :id, type: 'integer'
    field :firstname, value: -> (record) { record.first_name.to_s }, analyzer: 'substring'
    field :lastname, value: -> (record) { record.last_name.to_s }, analyzer: 'substring'
    field :email, analyzer: 'substring'
    field :account, value: -> (record) { record.account.name.to_s }, analyzer: 'substring'
    field :inquiry, value: -> (record) { record.inquiries.count }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
