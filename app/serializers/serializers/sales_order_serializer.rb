class Serializers::SalesOrderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :sales_order_rows, :quantity
end