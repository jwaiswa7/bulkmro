class Serializers::SalesQuoteSerializer
  include FastJsonapi::ObjectSerializer
  attribute :rows
end