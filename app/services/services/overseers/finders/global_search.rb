class Services::Overseers::Finders::GlobalSearch < Services::Overseers::Finders::BaseFinder
  def call
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end

    @indexed_records = non_paginated_records
  end

  def all_records
    indexed_records = index_klass.all

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    if @prefix.present?
      indexed_records = search_as_to_type(indexed_records, @prefix)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: index_klass.fields
      }
    )


    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    if @prefix.present?
      indexed_records = search_as_to_type(indexed_records, @prefix)
    end
    indexed_records
  end

  def search_as_to_type(indexed_records, prefix)
    indexed_records = indexed_records.query(
      multi_match: {
          query: prefix,
          fields: ['inquiry_number_autocomplete.autocomplete^3', 'products.product_autocomplete.autocomplete', 'company.company_autocomplete.autocomplete', 'account.account_autocomplete.autocomplete'],
          type: 'best_fields'
      }
    )
    indexed_records
  end

  def model_klass
    Inquiry
  end

  def index_klass
    'SuggestionsIndex'.constantize
  end
end
