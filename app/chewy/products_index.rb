class ProductsIndex < BaseIndex
  define_type Product.approved.with_includes do
    field :id
    field :brand, value: -> (record) { record.brand.to_s }, analyzer: 'substring_analyzer'
    field :category, value: -> (record) { record.category.to_s }, analyzer: 'substring_analyzer'

    field :sku, analyzer: 'sku_substring_analyzer'
    field :name, analyzer: 'substring_analyzer'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

end