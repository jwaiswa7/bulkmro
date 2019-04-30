class SuggestionsIndex < BaseIndex
  define_type Inquiry.all do
    field :id
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :inquiry_number_autocomplete, type: 'text',value: -> (record) { record.inquiry_number.to_s } do
      field :autocomplete, type: 'text', analyzer: 'autocomplete'
    end
    field :inquiry_quote_autocomplete, type: 'text', value: -> (record) {[record.inquiry_number, (' > sales_quote > ' if record.final_sales_quote.present?),(record.final_sales_quote.id if record.final_sales_quote.present?)].join(' ')} do
      field :keywordstring, type: 'text', analyzer: 'keyword_analyzer'
      field :edgengram, type: 'text', analyzer: 'edge_ngram_analyzer', search_analyzer: 'edge_ngram_search_analyzer'
      field :completion, type: 'completion'
      field :autocomplete, type: 'text', analyzer: 'autocomplete'
    end

    field :final_sales_orders do
      field :inquiry_order_autocomplete, type: 'text',value: -> (record) {[record.inquiry.inquiry_number, ' > sales_order >',record.order_number].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

  end
end
