class AddressesIndex < BaseIndex
  define_type Address.has_company_id do
    field :id, type:'integer'
    field :state_name, value: -> (record) { record.state_name.to_s }, analyzer: 'substring'
    field :city_name, value: -> (record) { record.city_name.to_s }, analyzer: 'substring'
    field :gst, value: -> (record) { record.gst.to_s }, analyzer: 'substring'
    # field :pan, value: -> (record) { record.company.pan.to_s }, analyzer: 'substring'
  end
end