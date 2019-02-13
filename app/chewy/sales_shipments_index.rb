class SalesShipmentsIndex < BaseIndex
  statuses = SalesShipment.statuses

  define_type SalesShipment.all.with_includes do
    field :id

    field :sales_order_id, value: -> (record) { record.sales_order.id if record.sales_order.present? }
    field :sales_order_number, value: -> (record) { record.sales_order.order_number.to_i }, type: "integer"
    field :sales_order_number_s, value: -> (record) { record.sales_order.order_number.to_s }, analyzer: "substring"
    field :shipment_number, value: -> (record) { record.shipment_number.to_i }, type: "integer"
    field :shipment_number_s, value: -> (record) { record.shipment_number.to_s }, analyzer: "substring"
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: "integer"
    field :inquiry_number_s, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: "substring"
    field :status, value: -> (record) { statuses[record.status] }
    field :status_key, value: -> (record) { statuses[record.status] }, type: "integer"
    field :status_s, value: -> (record) { record.status }, analyzer: "substring"
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: "substring"
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: "substring"
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :shipment_grn
    field :packing_remarks

    field :created_at, type: "date"
    field :updated_at, type: "date"
  end
end
