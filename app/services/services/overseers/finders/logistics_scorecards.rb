class Services::Overseers::Finders::LogisticsScorecards < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = index_klass.limit(model_klass.count).order(sort_definition)

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: %w[inquiry_number_string]
      }
    ).order(sort_definition)

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
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
    SalesOrder
  end

  def index_klass
    'LogisticsScorecardsIndex'.constantize
  end
end
