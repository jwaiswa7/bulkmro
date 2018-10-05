class ProductsIndex < BaseIndex
  define_type Product.approved.with_includes do
    field :id
    field :brand, value: -> (record) { record.brand.to_s }, analyzer: 'letter'
    field :sku, analyzer: 'edge_ngram'
    field :name, analyzer: 'edge_ngram'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

  def self.fields
    [:sku]
  end
end