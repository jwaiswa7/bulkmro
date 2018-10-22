class PurchaseOrdersIndex < BaseIndex
  define_type PurchaseOrder.all.with_includes do
    field :id

    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }
    field :inquiry, value: -> (record) { record.inquiry.to_s }, analyzer: 'substring'

    field :po_number, value: -> (record) { record.po_number.to_i }, type: 'integer'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

  def self.fields
    [:inquiry_id, :inquiry, :po_number, :created_at, :updated_at, :created_by, :updated_by ]
  end
end