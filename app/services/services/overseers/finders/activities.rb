class Services::Overseers::Finders::Activities < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Activity
  end

  def all_records
    indexed_records = super

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

  def perform_query(query)
    query = query[0, 35]
    indexed_records = index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[created_by account_name company_name inquiry_number_string contact_name purpose activity_type],
      }
    )

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end


    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end
end
