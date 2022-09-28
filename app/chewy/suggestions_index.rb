class SuggestionsIndex < BaseIndex
  define_type Inquiry.all do
    field :id
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :inquiry_number_autocomplete, type: 'text', value: -> (record) { ['Inquiry: ', record.inquiry_number.to_s].join(' ') } do
      field :autocomplete, type: 'text', analyzer: 'autocomplete'
    end

    field :final_sales_quote do
      field :inquiry_order_autocomplete, type: 'text', value: -> (record) {['Inquiry: ', record.inquiry.inquiry_number, ' Sales Quote: ', record.id].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :final_sales_orders do
      field :inquiry_order_autocomplete, type: 'text', value: -> (record) {['Inquiry: ', record.inquiry.inquiry_number, ' Sales Order: ', record.order_number].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :company do
      field :id, type: 'text'
      field :company_autocomplete, type: 'text', value: -> (record) {['Company: ', record.to_s].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :account do
      field :id, type: 'text'
      field :account_autocomplete, type: 'text', value: -> (record) {['Account: ', record.to_s].join(' ')} do
        field :autocomplete, type: 'text', analyzer: 'autocomplete'
      end
    end

    field :products do
      field :id, type: 'text'
      field :product_autocomplete, value: -> (record) {['Product: ', record.to_s].join(' ')}, type: 'text' do
        field :autocomplete, type: 'text',  analyzer: 'autocomplete'
      end
    end
  end
end
