class Services::Overseers::Finders::CompanyReports < Services::Overseers::Finders::BaseFinder
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

    indexed_records = aggregation_company_report(indexed_records)
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
    indexed_records = aggregation_company_report(indexed_records)
    indexed_records
  end

  def aggregation_company_report(indexed_records)
    if @company_report_params.present?
      from = @company_report_params['date_range'].split('~').first.to_date.strftime('%d-%m-%Y')
      to = @company_report_params['date_range'].split('~').last.to_date.strftime('%d-%m-%Y')
      date_range = {from: from, to: to, key: 'custom-range'}
    else
      date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
    end
    indexed_records = indexed_records.aggregations(
        'company_over_month': {
            date_range: {
                field: 'created_at',
                format: 'dd-MM-yyy',
                ranges: [
                    date_range
                ],
                keyed: true
            },
            aggs: {
                'inquiries': {
                    'terms': {'field': 'inside_sales_owner_id', size: 500},
                    aggs: {
                        sales_invoices: {
                            sum: {
                                field: 'invoices_count'
                            }
                        },
                        sales_quotes: {
                            sum: {
                                field: 'sales_quote_count'
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
                        },
                        total_sales_value: {
                            sum: {
                                field: 'total_quote_value'
                            }
                        },
                        total_order_value: {
                            sum: {
                                field: 'total_order_value'
                            }
                        },
                        revenue: {
                            sum: {
                                field: 'revenue'
                            }
                        },
                        company: {
                            sum: {
                                field: 'company'
                            }
                        },
                        account: {
                            cardinality: {
                                field: 'account'
                            }
                        }
                    }
                }
            }
        }
    )
    indexed_records
  end

  def model_klass
    Company
  end
end

