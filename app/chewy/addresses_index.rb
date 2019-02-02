class AddressesIndex < BaseIndex
  define_type Address.has_company_id.with_includes do
    field :id, type:'integer'
    field :address, value: -> (record) { record.to_s }, analyzer: 'substring'
    field :state_id, value: -> (record) { record.try(:state_id) }
    field :state, value: -> (record) { record.try(:state).try(:name).to_s }, analyzer: 'substring'
    field :city_name, value: -> (record) { record.city_name.to_s }, analyzer: 'substring'
    field :gst, value: -> (record) { record.gst.to_s }, analyzer: 'substring'
    field :is_gst_valid, value: -> (record) { record.validate_gst }
    field :pincode, value: -> (record) { record.try(:pincode) }
    field :company_id, value: -> (record) { record.company_id }
    field :company, value: -> (record) { record.company.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
  end
end