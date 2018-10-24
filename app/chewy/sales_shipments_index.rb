class SalesShipmentsIndex < BaseIndex
  define_type SalesShipment.all.with_includes do
    field :id

    field :sales_order_id, value: -> (record) { record.sales_order.id if record.sales_order.present? }
    field :sales_order, value: -> (record) { record.sales_order.to_s }, analyzer: 'substring'
    field :shipment_number, value: -> (record) { record.shipment_number.to_i }, type: 'integer'
    field :status, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :shipment_grn
    field :packing_remarks

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

  def self.fields
    [:sales_order_id, :sales_order, :shipment_number, :status, :shipment_grn, :packing_remarks, :created_at, :updated_at, :created_by, :updated_by ]
  end
end