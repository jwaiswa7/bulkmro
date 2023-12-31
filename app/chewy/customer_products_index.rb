class CustomerProductsIndex < BaseIndex
  index_scope CustomerProduct.all
    field :id, type: 'integer'
    field :company_id, type: 'integer'
    field :company, value: -> (record) { record.company.name.to_s }, analyzer: 'substring'
    field :has_images, value: -> (record) { (record.images.attached? ? record.images.attached? : record.product.images.attached?) }
    field :sku, analyzer: 'sku_substring'
    field :name, analyzer: 'substring'
    field :brand, value: -> (record) { record&.best_brand&.name }, analyzer: 'substring'
    field :category, value: -> (record) { record&.best_category&.name }, analyzer: 'substring'
    field :mpn, value: -> (record) { record.product.try(:mpn).to_s }, analyzer: 'substring'
    field :tags, value: -> (record) { record.tags.ids.map(&:to_s) }, analyzer: 'substring'
    field :customer_price, type: 'integer'
    field :created_at, type: 'date'
    field :product_created_at , value: -> (record) { record.product&.created_at} , type: 'date'
    field :image,  value: -> (record) { record.images.present? ? 1: 0 }, type: 'integer'
    field :updated_at, type: 'date'
    field :bp_catalog_name, value: -> (record) { record.try(:bp_catalog_name) }, analyzer: 'substring'
    field :bp_catalog_sku, value: -> (record) { record.try(:bp_catalog_sku) }, analyzer: 'substring'
    field :inquiries, type: 'integer',  value: -> (record) { record.product.inquiry_products.count }
    field :stock, type: 'integer', value: -> (record) { record.product.stocks.where(warehouse_id: Warehouse.find('rQJfAO').id).sum(&:instock).to_i > 0 ? 1 : 0 }
    field :qty_in_stock, type: 'integer', value: -> (record) { record.qty_in_stock(warehouse: 'rQJfAO') }
    field :published, type: 'integer', value: -> (record) { record.published? ? 1: 0 }
end
