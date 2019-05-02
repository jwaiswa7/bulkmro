class SuggestionsIndex < BaseIndex
  define_type Inquiry.all do
    field :id
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :inquiry_number_autocomplete, type: 'text',value: -> (record) { record.inquiry_number.to_s } do
      field :autocomplete, type: 'text', analyzer: 'autocomplete'
    end

    field :final_sales_quote do
      field :inquiry_order_autocomplete, type: 'text',value: -> (record) {[record.inquiry.inquiry_number, ' > sales_quote >',record.id].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :final_sales_orders do
      field :inquiry_order_autocomplete, type: 'text',value: -> (record) {[record.inquiry.inquiry_number, ' > sales_order >',record.order_number].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :company do
      field :id, type: 'integer'
      field :company_autocomplete, type: 'text', value: -> (record) {['company > ', record.id].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end
  end
end
