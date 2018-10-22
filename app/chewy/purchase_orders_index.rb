class PurchaseOrdersIndex < BaseIndex
  define_type PurchaseOrder.all.with_includes do
    field :id

    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }
    field :inquiry, value: -> (record) { record.inquiry.to_s }, analyzer: 'substring'

    field :po_number, value: -> (record) { record.po_number.to_i }, type: 'integer'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end