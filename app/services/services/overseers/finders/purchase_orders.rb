class Services::Overseers::Finders::PurchaseOrders < Services::Overseers::Finders::BaseFinder
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
    indexed_records = indexed_records.aggregations(aggregate_by_status("po_status"))
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: "and", fields: %w[ po_number_string^3 inquiry inside_sales_owner outside_sales_owner supplier customer po_status_string po_date] })

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
    indexed_records = indexed_records.aggregations(aggregate_by_status("po_status"))
    indexed_records
  end


  def model_klass
    PurchaseOrder
  end
end
