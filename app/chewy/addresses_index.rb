class AddressesIndex < BaseIndex
  define_type Address.has_company_id.with_includes do
    field :id, type:'integer'
    field :state_id, value: -> (record) { record.try(:state_id) }
    field :state, value: -> (record) { record.try(:state).try(:name).to_s }, analyzer: 'substring'
    field :city_name, value: -> (record) { record.city_name.to_s }, analyzer: 'substring'
    field :gst, value: -> (record) { record.gst.to_s }, analyzer: 'substring'
    field :is_gst_valid, value: -> (record) { validate_gst(record.gst.to_s) }
    field :company_id, value: -> (record) { record.company_id }
    field :pan, value: -> (record) { record.company.pan.to_s }, analyzer: 'substring'
    field :is_pan_valid, value: -> (record) { validate_pan(record.company.pan.to_s) }
    field :created_at, type: 'date'
  end

  def self.validate_gst(gst)
    if gst.match(/^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/)
      true
    else
      false
    end
  end

  def self.validate_pan(pan)
    if pan.match(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
      true
    else
      false
    end
  end
end