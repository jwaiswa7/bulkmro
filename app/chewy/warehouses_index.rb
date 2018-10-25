class WarehousesIndex < BaseIndex
  define_type Warehouse.all do
    field :id, type:'integer'
    field :name, analyzer: 'substring'
    field :state_name , value: -> (record) { record.address.state.name.to_s }, analyzer: 'substring'
    field :remote_uid, analyzer: 'substring'
    field :gst , value: -> (record) { record.address.gst.to_s }, analyzer: 'substring'
    field :location , value: -> (record) { record.address.city_name.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end