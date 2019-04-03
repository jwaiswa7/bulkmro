class Services::Overseers::Finders::PipelineReports < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      super
    end

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = aggregation_pipeline_report(indexed_records)
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: %w[inside_sales_owner]
      }
    ).order(sort_definition)

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records = aggregation_pipeline_report(indexed_records)
    indexed_records
  end

  def aggregation_pipeline_report(indexed_records)
    if @pipeline_report_params.present?
      from = @pipeline_report_params['date_range'].split('~').first.to_date.strftime('%d-%m-%Y')
      to = @pipeline_report_params['date_range'].split('~').last.to_date.strftime('%d-%m-%Y')
      date_range = {from: from, to: to, key: 'custom-range'}
    else
      date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
    end
    indexed_records = indexed_records.aggregations(
      'inquiries_over_time': {
          'date_histogram': {
              'field': 'created_at',
              'interval': 'month',
              keyed: true,
              order: {_key: 'desc'}
          },
          aggs: {
              'pipeline': {
                  'terms': {'field': 'status_key'},
                  aggs: {
                      inquiry_value: {
                          sum: {
                              field: 'calculated_total'
                          }
                      }
                  }
              },
              'sum_monthly_sales': {
                  'sum_bucket': {
                      'buckets_path': 'pipeline>inquiry_value'
                  }
              }
          }
      },
      'summary_row': {
          'terms': {'field': 'status_key'},
          aggs: {
              inquiry_summary: {
                  sum: {
                      field: 'calculated_total'
                  }
              }
          }
      }
    )
    indexed_records
  end

  def model_klass
    Inquiry
  end
end
