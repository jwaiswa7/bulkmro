class Services::Overseers::Finders::GlobalSearch < Services::Overseers::Finders::BaseFinder
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

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    if '5670'.present?
      indexed_records = search_as_to_type(indexed_records, '5670')
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

    if '5670'.present?
      indexed_records = search_as_to_type(indexed_records, '5670')
    end
    indexed_records
  end

  def search_as_to_type(indexed_records, prefix)
    indexed_records = indexed_records.query(
        "match": {
            "inquiry_number_autocomplete.autocomplete": '5670'
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
