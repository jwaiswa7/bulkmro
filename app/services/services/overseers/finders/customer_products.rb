class Services::Overseers::Finders::CustomerProducts < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def all_records
    indexed_records = index_klass.all.order(sort_definition)

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def model_klass
    CustomerProduct
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(
      multi_match: {
        query: query,
        operator: 'and',
        fields: %w[brand^4 category^4 name^3 sku^3],
        minimum_should_match: '100%'
      }
    )
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    indexed_records
  end
end
