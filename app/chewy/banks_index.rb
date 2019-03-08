class BanksIndex < BaseIndex
  define_type Bank.all do
    field :id, type: 'integer'
    field :code, value: -> (record) {record.code}, analyzer: 'substring'
    field :name, value: -> (record) {record.name}, analyzer: 'substring'
    field :country_code, value: -> (record) {record.country_code}, analyzer: 'substring'
    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
  end
end
