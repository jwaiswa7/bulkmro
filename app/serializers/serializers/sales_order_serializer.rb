class Serializers::SalesOrderSerializer
  include FastJsonapi::ObjectSerializer
  has_many :rows
end