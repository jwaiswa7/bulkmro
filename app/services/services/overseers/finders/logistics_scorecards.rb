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
          fields: %w[inquiry_number_string company]
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
    date_range = {from: Date.new(2019, 01, 01).strftime('%Y-%m-%d'), to: Date.today.end_of_month.strftime('%Y-%m-%d'), key: 'custom-range'}

    logistics_scorecard_query = {
        'overall_scorecard': {
            'date_histogram': {
                'field': 'cp_committed_date',
                'interval': 'month',
                keyed: true,
                'order': { _key: 'asc' }
            },
            aggs: {
                'scorecard': {
                    'terms': {
                        'field': 'delay_bucket',
                    }
                },
                'sum_delay_buckets': {
                    'sum_bucket': {
                        'buckets_path': 'scorecard>_count'
                    }
                }
            }
        },
        'ownerwise_scorecard': {
            'date_histogram': {
                'field': 'cp_committed_date',
                'interval': 'month',
                keyed: true,
                'order': { _key: 'asc' }
            },
            aggs: {
                'scorecard': {
                    'terms': {
                        'field': 'logistics_owner_id',
                        'order': { _key: 'asc'}
                    },
                    aggs: {
                        'delay_bucket': {
                            'terms': {
                                'field': 'delay_bucket'
                            }
                        },
                        'sum_delay_buckets': {
                            'sum_bucket': {
                                'buckets_path': 'delay_bucket>_count'
                            }
                        },
                        'delay_reason': {
                            'terms': {
                                'field': 'delay_reason'
                            }
                        },
                        'sum_delay_reason_buckets': {
                            'sum_bucket': {
                                'buckets_path': 'delay_reason>_count'
                            }
                        }
                    }
                }
            }
        },
        'delay_reason_monthwise_scorecard': {
            'date_histogram': {
                'field': 'cp_committed_date',
                'interval': 'month',
                keyed: true,
                'order': { _key: 'asc' }
            },
            aggs: {
                'scorecard': {
                    'terms': {
                        'field': 'delay_reason',
                    }
                },
                'sum_delay_buckets': {
                    'sum_bucket': {
                        'buckets_path': 'scorecard>_count'
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
