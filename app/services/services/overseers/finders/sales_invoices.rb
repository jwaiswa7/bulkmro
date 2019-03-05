class Services::Overseers::Finders::SalesInvoices < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_value('inquiry_present', true)))
    else
      super.filter(filter_by_value('inquiry_present', true))
    end

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if @base_filter.present?
      indexed_records =  indexed_records.filter(@base_filter)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = indexed_records.aggregations(aggregate_by_status('status_key'))

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and', fields: %w[invoice_number_string^3 sales_order_number_string account_string company_string^4 status_string inquiry_number_string inside_sales_owner outside_sales_owner] }).order(sort_definition).order(sort_definition)

    indexed_records = indexed_records.filter(filter_by_value('inquiry_present', true))

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_value('inquiry_present', true)))
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

    indexed_records = indexed_records.aggregations(aggregate_by_status('status_key'))

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    indexed_records
  end

  def model_klass
    SalesInvoice
  end

  def sort_definition
    { created_at: :desc }
  end
end
