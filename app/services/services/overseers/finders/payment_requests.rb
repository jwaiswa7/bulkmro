class Services::Overseers::Finders::PaymentRequests < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    PaymentRequest
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_status))
    else
      super
    end

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end
    indexed_records = indexed_records.aggregations(aggregate_by_status('status'))

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and', fields: %w[updated_by_id status_string inquiry_number_string^5 inside_sales_owner outside_sales_owner ] }).order(sort_definition)

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_status))
    else
      indexed_records = indexed_records
    end

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status.to_i))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end
    indexed_records = indexed_records.aggregations(aggregate_by_status('status'))
    indexed_records
  end

end
