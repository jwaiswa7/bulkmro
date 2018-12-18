class CompaniesIndex < BaseIndex
  define_type Company.all.with_includes do
    field :id, type: 'integer'
    field :account_id, value: -> (record) { record.account_id }
    field :name, value: -> (record) { record.name }
    field :addresses, value: -> (record) { record.addresses.size }
    field :contacts, value: -> (record) { record.contacts.size }
    field :inquiries, value: -> (record) { record.inquiries.size }
    field :is_supplier, value: -> (record) { record.is_supplier?}
    field :is_customer, value: -> (record) { record.is_customer? }
    field :sap_status, value: -> (record) { record.synced? }
    field :created_at, value: -> (record) { record.created_at },type: 'date'
    field :updated_at, value: -> (record) { record.updated_at },type: 'date'
  end
end