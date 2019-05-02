class ProductsIndex < BaseIndex
  define_type Product.approved.with_includes do
    field :id
    field :product_id, value: -> (record) {record.id}
    field :brand_id, value: -> (record) {record.brand_id}
    field :brand, value: -> (record) {record.brand.to_s}, analyzer: 'substring'
    field :category, value: -> (record) {record.category.to_s}, analyzer: 'substring'
    field :approved, value: -> (record) {record.approval.try(:created_at)}
    field :approved_at, value: -> (record) {record.approval.try(:created_at) if record.approval.present?}, type: 'date'
    field :has_images, value: -> (record) {record.images.attached?}
    field :is_service
    field :sku, value: -> (record) {record.sku.to_s}, analyzer: 'sku_substring', fielddata: true
    field :name, analyzer: 'substring'
    field :namecomplete, type: 'text', value: -> (record) {record.name} do
      field :keywordstring, type: 'text', analyzer: 'keyword_analyzer'
      field :edgengram, type: 'text', analyzer: 'edge_ngram_analyzer', search_analyzer: 'edge_ngram_search_analyzer'
      field :completion, type: 'completion'
    end
    field :mpn, value: -> (record) {record.mpn.to_s}, analyzer: 'substring', type: 'text', fielddata: true
    field :total_pos, value: -> (record) {record.total_pos}, type: 'integer'
    field :total_quotes, value: -> (record) {record.total_quotes}, type: 'integer'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by, value: -> (record) {record.created_by.to_s}
    field :updated_by, value: -> (record) {record.updated_by.to_s}
    field :is_not_kit, value: -> (record) { !record.is_kit }
  end
end
