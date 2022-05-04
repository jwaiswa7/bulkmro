class Services::Overseers::Finders::OutwardDispatches < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    OutwardDispatch
  end

  def all_records
    indexed_records = super

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, OutwardDispatch.statuses[@status]))
    end

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

  def get_summary_records(indexed_records)
    status_records = indexed_records.aggregations(aggregate_by_status('status'))
    material_delivery_records = indexed_records.aggregations(aggregate_by_status('material_delivery_status'))
    summary_records = [status_records, material_delivery_records]
    summary_records
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(
      multi_match: {
                        query: query,
                        operator: 'and',
                        fields: %w[inquiry_number_string sales_order_number_string ar_invoice_request_number_string]
                    }
    )
    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, OutwardDispatch.statuses[@status]))
    end

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
