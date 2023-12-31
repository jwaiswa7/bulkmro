class SupplierProductsIndex < BaseIndex
  index_scope SupplierProduct.all 
    field :id, type: 'integer'
    field :supplier_id, type: 'integer'
    field :supplier, value: -> (record) { record.supplier.name.to_s }, analyzer: 'substring'
    field :has_images, value: -> (record) { (record.images.attached? ? record.images.attached? : record.product.images.attached?) }
    field :sku, analyzer: 'sku_substring'
    field :name, analyzer: 'substring'
    field :brand, value: -> (record) { record.brand.to_s }, analyzer: 'substring'
    field :category, value: -> (record) { record.category.to_s }, analyzer: 'substring'
    field :mpn, value: -> (record) { record.product.try(:mpn).to_s }, analyzer: 'substring'
    field :supplier_price, type: 'integer'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  
end
