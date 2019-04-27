class Services::Overseers::Finders::IfscCodes < Services::Overseers::Finders::BaseFinder
  def call
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end

    @indexed_records = non_paginated_records.page(page).per(per) if non_paginated_records.present?
    @indexed_records = non_paginated_records if !paginate
  end

  def all_records
    indexed_records = index_klass.all

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
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

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[ifsc_code^3 branch city district address contact bank],
          minimum_should_match: '100%'
      }
    )

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
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

  def suggestion(indexed_records, prefix)
    indexed_records = indexed_records.suggest(
      "ifsc-code-suggestions": {
          prefix: prefix,
          completion: {
              field: 'ifsc_complete.completion',
              size: 15,
              skip_duplicates: true
          }
      }
    )
    indexed_records
  end

  def search_as_to_type(indexed_records, prefix)
    indexed_records = indexed_records.query(
      "match": {
          "ifsc_complete.autocomplete": prefix
      }
    )
    indexed_records
  end

  def model_klass
    IfscCode
  end
end
