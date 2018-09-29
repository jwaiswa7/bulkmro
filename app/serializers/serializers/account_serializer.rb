class Serializers::AccountSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :alias, :created_at, :updated_at
end