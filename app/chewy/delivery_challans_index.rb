class DeliveryChallansIndex < BaseIndex
  define_type DeliveryChallan.with_includes.all do
    field :id, type: 'integer'
    field :inquiry_id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :order_number, value: -> (record) { record.sales_order.order_number.to_i if record.sales_order.present? }, type: 'integer'
    field :company, value: -> (record) { record.inquiry.company.to_s }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.inquiry.company.id }, type: 'integer'
    field :delivery_challan_number, analyzer: 'substring', fielddata: true
    field :sales_order_id, type: 'integer'
    field :ar_invoice_request_id, type: 'integer'
    field :supplier_bill_from_id, type: 'integer'
    field :supplier_ship_from_id, type: 'integer'
    field :customer_bill_from_id, type: 'integer'
    field :customer_ship_from_id, type: 'integer'
    field :goods_type, analyzer: 'substring'
    field :reason, analyzer: 'substring'
    field :goods_type, analyzer: 'substring'
    field :customer_order_date, type: 'date'
    field :sales_order_date, type: 'date'
    field :created_by_id, type: 'integer'
    field :created_at, type: 'date'
  end
end

