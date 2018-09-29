class Serializers::BaseSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :created_at, :updated_at
end