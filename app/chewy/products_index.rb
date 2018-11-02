class ProductsIndex < BaseIndex
  define_type Product.approved.with_includes do
    field :id
    field :brand, value: -> (record) { record.brand.to_s }, analyzer: 'substring'
    field :category, value: -> (record) { record.category.to_s }, analyzer: 'substring'

    field :sku, analyzer: 'sku_substring'
    field :name, analyzer: 'substring'
    field :mpn, value: -> (record) { record.mpn.to_s },analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_, value: -> (record) { record.created_by.to_s }
    field :updated_by, value: -> (record) { record.updated_by.to_s }
  end

end