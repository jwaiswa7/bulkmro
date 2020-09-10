class DeliveryChallansIndex < BaseIndex
  define_type DeliveryChallan.all do
    field :id, type: 'integer'
    field :inquiry_id, type: 'integer'
    field :sales_order_id, type: 'integer'
    field :purchase_order_id, type: 'integer'
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

