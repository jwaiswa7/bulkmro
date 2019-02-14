# frozen_string_literal: true

class TaxCodesIndex < BaseIndex
  define_type TaxCode.all do
    field :id, type: 'integer'
    field :code, value: -> (record) { record.code.to_s }, analyzer: 'substring'
    field :taxpercentage, value: -> (record) { record.tax_percentage.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
