class Services::Overseers::Finders::CustomerOrderStatusReports < Services::Overseers::Finders::BaseFinder
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

    if @customer_order_status_report_params.present?
      if @customer_order_status_report_params['procurement_specialist'].present?
        executives = @customer_order_status_report_params['procurement_specialist'].to_i
        indexed_records = indexed_records.filter(filter_by_value('inside_sales_owner_id', executives))
      end
      if @customer_order_status_report_params['outside_sales_owner'].present?
        executives = @customer_order_status_report_params['outside_sales_owner'].to_i
        indexed_records = indexed_records.filter(filter_by_value('outside_sales_owner_id', executives))
      end
      if @customer_order_status_report_params['procurement_operations'].present?
        executives = @customer_order_status_report_params['procurement_operations'].to_i
        indexed_records = indexed_records.filter(filter_by_value('procurement_operations_id', executives))
      end
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: %w[inquiry_number_string account company order_number_string],
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
    'CustomerOrderStatusReportIndex'.constantize
  end
end
