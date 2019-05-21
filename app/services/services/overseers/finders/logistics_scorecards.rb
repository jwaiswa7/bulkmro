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

    indexed_records = aggregation_logistics_scorecard(indexed_records)
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

    indexed_records = aggregation_logistics_scorecard(indexed_records)
    indexed_records
  end

  def aggregation_logistics_scorecard(indexed_records)
    date_range = {from: Date.new(2018, 04, 01).strftime('%Y-%m-%d'), to: Date.today.strftime('%Y-%m-%d'), key: 'custom-range'}

    logistics_scorecard_query = {
        'overall_scorecard': {
            'date_histogram': {
                'field': 'cp_committed_date',
                'interval': 'month',
                keyed: true,
                'order': {_key: 'desc'}
            },
            aggs: {
                'scorecard': {
                    'terms': {
                        'field': 'delay_bucket'
                    }
                }
            }
        },
        'ownerwise_scorecard': {
            'date_histogram': {
                'field': 'cp_committed_date',
                'interval': 'month',
                keyed: true,
                'order': {_key: 'desc'}
            },
            aggs: {
                'scorecard': {
                    'terms': {
                        'field': 'logistics_owner_id'
                    },
                    aggs: {
                        'delay_bucket': {
                            'terms': {
                                'field': 'delay_bucket'
                            }
                        }
                    }
                }
            }
        }
    }

    indexed_records = indexed_records.aggregations(
      'logistics_scorecard_filter': {
          'date_range': {
              'field': 'cp_committed_date',
              'format': 'yyyy-MM-dd',
              'ranges': [
                  date_range
              ],
              'keyed': 'true'
          },
          'aggs': logistics_scorecard_query
      }
    )
    indexed_records
  end

  def model_klass
    SalesInvoice
  end

  def index_klass
    'LogisticsScorecardsIndex'.constantize
  end
end
