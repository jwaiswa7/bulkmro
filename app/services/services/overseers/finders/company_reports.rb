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
            fields: %w[]
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
                    'terms': {'field': 'company_key', size: 500},
                    aggs: {

                        inquiries_size: {
                            sum: {
                                field: 'inquiries_size'
                            }
                        },

                        total_inquiries: {
                            sum: {
                                field: 'inquiries'
                            }
                        },

                        sales_quotes: {
                            sum: {
                                field: 'sales_quote_count'
                            }
                        },


                        total_sales_value: {
                            sum: {
                                field: 'total_quote_value'
                            }
                        },
                        expected_orders: {
                            sum: {
                                field: 'expected_order'
                            }
                        },
                        total_expected_value: {
                            sum: {
                                field: 'expected_value'
                            }
                        },
                        total_sales_orders: {
                            sum: {
                                field: 'sales_order_count'
                            }
                        },
                        total_order_value: {
                            sum: {
                                field: 'total_order_value'
                            }
                        },
                        order_margin: {
                            sum: {
                                field: 'total_margin'
                            }
                        },
                        sales_invoices: {
                            sum: {
                                field: 'invoices_count'
                            }
                        },
                        amount_invoiced: {
                            sum: {
                                field: 'amount_invoiced'
                            }
                        },
                        margin_percentage: {
                            sum: {
                                field: 'margin_percentage'
                            }
                        },
                        invoice_margin: {
                            sum: {
                                field: 'invoice_margin_percentage'
                            }
                        },
                        cancelled_invoiced: {
                            sum: {
                                field: 'cancelled_invoiced'
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

