class Services::Overseers::Finders::CompanyReports < Services::Overseers::Finders::BaseFinder
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
    indexed_records = aggregation_kra_report(indexed_records)
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: %w[name account]
      }
    ).order(sort_definition)


    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records = aggregation_kra_report(indexed_records)
    indexed_records
  end

  def model_klass
    Company
  end

  def index_klass
    'NewCompanyReportsIndex'.constantize
  end

  def aggregation_kra_report(indexed_records)
    if @company_report_params.present?
      if @company_report_params['date_range'].present?
        from = @company_report_params['date_range'].split('~').first.to_date.strftime('%d-%m-%Y')
        to = @company_report_params['date_range'].split('~').last.to_date.strftime('%d-%m-%Y')
        date_range = {from: from, to: to, key: 'custom-range'}
      else
        date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
      end
    else
      date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
    end
    indexed_records = indexed_records.aggregations(
        'company_report_over_month': {
            date_range: {
                field: 'created_at',
                format: 'dd-MM-yyy',
                ranges: [
                    date_range
                ],
                keyed: true
            },
            aggs: {
                'company_report': {
                    'terms': {'field': 'company_key', size: 10000},
                    aggs: {
                        live_inquiries: {
                          sum: {
                              field: 'live_inquiry'
                          }
                        },
                        sales_invoices: {
                            sum: {
                                field: 'invoices_count'
                            }
                        },
                        sales_invoices_total: {
                            sum: {
                                field: 'invoices.calculated_total'
                            }
                        },
                        sales_quotes: {
                            sum: {
                                field: 'final_sales_quote'
                            }
                        },
                        sales_quotes_total: {
                            sum: {
                                field: 'final_sales_quote_total'
                            }
                        },
                        sales_quotes_margin_percentage: {
                            sum: {
                                field: 'final_sales_quote_margin_percentage'
                            }
                        },
                        sales_orders: {
                            sum: {
                                field: 'sales_order_count'
                            }
                        },
                        sales_orders_total: {
                            sum: {
                                field: 'final_sales_orders.calculated_total'
                            }
                        },
                        sales_orders_margin: {
                            sum: {
                                field: 'final_sales_orders.calculated_total_margin'
                            }
                        },
                        sales_orders_margin_percentage: {
                            sum: {
                                field: 'final_sales_orders.calculated_total_margin_percentage'
                            }
                        },
                        expected_orders: {
                            sum: {
                                field: 'expected_order'
                            }
                        },
                        expected_orders_total: {
                            sum: {
                                field: 'expected_order_total'
                            }
                        },
                        sku: {
                            sum: {
                                field: 'sku'
                            }
                        },
                        cancelled_invoiced: {
                            sum:{
                                field: 'cancelled_invoiced'
                            }
                        },
                        cancelled_invoiced_total: {
                            sum:{
                                field: 'cancelled_invoiced_total'
                            }
                        }

                    }
                }
            }
        }
    )
    indexed_records
  end

end
