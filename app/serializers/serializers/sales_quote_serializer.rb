class Serializers::SalesQuoteSerializer
  include FastJsonapi::ObjectSerializer
  attribute :rows

  has_many :sales_orders, serializer: Serializers::SalesOrderSerializer
end