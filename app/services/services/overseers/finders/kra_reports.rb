class Services::Overseers::Finders::KraReports < Services::Overseers::Finders::BaseFinder
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

    indexed_records = indexed_records.aggregations(
        {
            'inquiries': {
                terms: {field: 'inside_sales_owner_id'},
                aggs: {
                    sales_invoices: {
                        sum: {
                            field: 'invoices_count'
                        }
                    },
                    sales_orders: {
                        sum: {
                            field: 'sales_order_count'
                        }
                    },
                    expected_orders: {
                        sum: {
                            field: 'expected_order'
                        }
                    },
                    orders_won: {
                        sum: {
                            field: 'order_won'
                        }
                    }
                }
            }
        })
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
        multi_match: {
            query: query_string,
            operator: 'and',
            fields: index_klass.fields
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
    indexed_records
  end


  def model_klass
    Inquiry
  end
end
