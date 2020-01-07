class Services::Overseers::Finders::CustomerOrderStatusReports < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      index_klass.limit(model_klass.count).order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      index_klass.limit(model_klass.count).order(sort_definition)
    end

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
      if @customer_order_status_report_params['date_range'].present?
        indexed_records = filter_by_date_range(indexed_records, @customer_order_status_report_params['date_range'])
      else
        indexed_records = filter_by_date_range(indexed_records, "01-Apr-2018+~+#{Date.today.strftime('%d-%b-%Y')}")
      end
    end
    indexed_records
  end

  def filter_by_date_range(indexed_records, date_range)
    range = date_range.split('~')
    indexed_records = indexed_records.query(
      range: {
          'created_at': {
              "time_zone": '+05:30',
              gte: range[0].strip.to_date,
              lte: range[1].strip.to_date
          }
      }
    )
    indexed_records
  end

  def sort_definition
    {created_at: :asc}
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: ['inquiry_number_string', 'account', 'company', 'order_number_string', 'po_number_string', 'invoice_number_string']
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
      if @customer_order_status_report_params['date_range'].present?
        indexed_records = filter_by_date_range(indexed_records, @customer_order_status_report_params['date_range'])
      else
        indexed_records = filter_by_date_range(indexed_records, "01-Apr-2018+~+#{Date.today.strftime('%d-%b-%Y')}")
      end
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
