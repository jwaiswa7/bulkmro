class CompanyBanksIndex < BaseIndex
  define_type CompanyBank.all.with_includes do
    field :id, type: 'integer'
    field :company_id, value: -> (record) { record.company_id }
    field :country, value: -> (record) { record.country }, analyzer: 'substring'
    field :name, value: -> (record) { record.name }, analyzer: 'substring'
    field :code, value: -> (record) { record.code }, analyzer: 'substring'
    field :account_name, value: -> (record) { record.account_name }, analyzer: 'substring'
    field :account_number, value: -> (record) { record.account_number }
    field :branch, value: -> (record) { record.branch }, analyzer: 'substring'
    field :created_at, value: -> (record) { record.created_at },type: 'date'
    field :updated_at, value: -> (record) { record.updated_at },type: 'date'
  end
end