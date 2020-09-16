class Services::Overseers::Finders::DeliveryChallans < Services::Overseers::Finders::BaseFinder
  def call
    call_base
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
          fields: %w[inquiry_number order_number]
      }).order(sort_definition)

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


  def model_klass
    DeliveryChallan
  end
end
