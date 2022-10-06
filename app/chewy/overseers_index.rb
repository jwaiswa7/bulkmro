class OverseersIndex < BaseIndex
  index_scope Overseer.all
    field :id, type: 'integer'
    field :firstname, value: -> (record) { record.first_name.to_s }, analyzer: 'substring'
    field :lastname, value: -> (record) { record.last_name.to_s }, analyzer: 'substring'
    field :role, value: -> (record) { record.role.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  
end
