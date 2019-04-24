class IfscCodesIndex < BaseIndex
  define_type IfscCode.all do
    field :id
    field :ifsc_code, analyzer: 'sku_substring'
    field :ifsc_complete, type: 'text', value: -> (record) {[record.ifsc_code, record.branch].join(' ')} do
      field :keywordstring, type: 'text', analyzer: 'keyword_analyzer'
      field :edgengram, type: 'text', analyzer: 'edge_ngram_analyzer', search_analyzer: 'edge_ngram_search_analyzer'
      field :completion, type: 'completion'
    end
    field :branch, analyzer: 'substring'
    field :address, analyzer: 'substring'
    field :city, analyzer: 'substring'
    field :district, analyzer: 'substring'
    field :state, analyzer: 'substring'
    field :contact, analyzer: 'substring'
    field :bank_id, type: 'integer'
    field :bank, value: -> (record) {record.bank.to_s}, analyzer: 'substring'
    field :created_at, type: 'date'
    field :merged_address, value: -> (record) {[record.city, record.state].join(', ')}, analyzer: 'substring'
  end
end
