class Services::Overseers::Finders::PoRequests < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      super
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

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and ', fields: %w[ inquiry_number_string^3   po_request_string^3  supplier customer] }).order(sort_definition)

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
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

  # Sets the product model class to use for the index
  def model_klass
    PoRequest
  end
end
