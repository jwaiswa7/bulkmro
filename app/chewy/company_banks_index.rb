class CompanyBanksIndex < BaseIndex
  index_scope CompanyBank.all.with_includes
    field :id, type: 'integer'
    field :company_id, value: -> (record) { record.company_id }
    field :bank_id, value: -> (record) { record.bank_id }
    field :bank, value: -> (record) { record.bank.to_s }, analyzer: 'substring'
    field :code, value: -> (record) { record.bank.code }, analyzer: 'substring'
    field :account_name, value: -> (record) { record.account_name }, analyzer: 'substring'
    field :account_number, value: -> (record) { record.account_number }
    field :branch, value: -> (record) { record.branch }, analyzer: 'substring'
    field :created_at, value: -> (record) { record.created_at }, type: 'date'
    field :updated_at, value: -> (record) { record.updated_at }, type: 'date'
  
end
