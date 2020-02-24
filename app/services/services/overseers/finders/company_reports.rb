class Services::Overseers::Finders::CompanyReports < Services::Overseers::Finders::BaseFinder
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
    indexed_records = aggregation_company_report(indexed_records)

    sales_executives = Overseer.pipeline_executives


    if @company_report_params.present? && @company_report_params['procurement_specialist'].present?
      executives = @company_report_params['procurement_specialist'].to_i
      indexed_records = indexed_records.filter(filter_by_value('inside_sales_executive', executives))
    end
    if @company_report_params.present? && @company_report_params['outside_sales_owner'].present?
      executives = @company_report_params['outside_sales_owner'].to_i
      indexed_records = indexed_records.filter(filter_by_value('outside_sales_executive', executives))
    end
    if @company_report_params.present? && @company_report_params['sales_manager'].present?
      sales_executives = sales_executives.map {|o| o if o.parent_id == @company_report_params['sales_manager'].to_i}.compact
      indexed_records = indexed_records.filter(filter_for_self_and_descendants(['inside_sales_executive', 'outside_sales_executive', 'sales_manager_id'], sales_executives.pluck(:id)))
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: %w[name account_name company_name]
      }
    ).order(sort_definition)


    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records = aggregation_company_report(indexed_records)
    indexed_records
  end

  def model_klass
    Company
  end

  def index_klass
    'NewCompanyReportsIndex'.constantize
  end

  def aggregation_company_report(indexed_records)
    if @company_report_params.present?
      if @company_report_params['date_range'].present?
        from = @company_report_params['date_range'].split('~').first.to_date.beginning_of_day.strftime('%d-%m-%Y %H:%M:%S')
        to = @company_report_params['date_range'].split('~').last.to_date.end_of_day.strftime('%d-%m-%Y %H:%M:%S')
        date_range = {from: from, to: to, key: 'custom-range'}
      else
        date_range = {to: Date.today.end_of_day.strftime('%d-%m-%Y %H:%M:%S'), key: 'custom-range'}
      end
    else
      date_range = {to: Date.today.end_of_day.strftime('%d-%m-%Y %H:%M:%S'), key: 'custom-range'}
    end
    # Sub-bucket aggregations
    indexed_records = indexed_records.aggregations(
      'company_report_over_month': {
          date_range: {
              field: 'created_at',
              format: 'dd-MM-yyy H:m:s',
              ranges: [
                  date_range
              ],
              keyed: true
          },
          "aggs": {
              "accounts": {
                  "terms": {
                      "field": 'account_id',
                      "size": 10000
                  },
                  "aggs": {
                      "companies": {
                          "terms": {
                              "field": 'company_key',
                              "size": 10000
                          },
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
                              sales_invoices_margin: {
                                  sum: {
                                      field: 'invoices_total_margin'
                                  }
                              },
                              sales_invoices_total: {
                                  sum: {
                                      field: 'invoice_total'
                                  }
                              },
                              sales_quotes: {
                                  sum: {
                                      field: 'sales_quotes_count'
                                  }
                              },
                              sales_quotes_total: {
                                  sum: {
                                      field: 'sales_quotes_total'
                                  }
                              },
                              sales_quotes_margin_percentage: {
                                  sum: {
                                      field: 'sales_quotes_margin_percentage'
                                  }
                              },
                              sales_orders: {
                                  sum: {
                                      field: 'sales_orders_count'
                                  }
                              },
                              sales_orders_total: {
                                  sum: {
                                      field: 'sales_orders_total'
                                  }
                              },
                              sales_orders_margin: {
                                  sum: {
                                      field: 'sales_orders_total_margin'
                                  }
                              },
                              sales_orders_margin_percentage: {
                                  sum: {
                                      field: 'sales_orders_overall_margin_percentage'
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
                                  sum: {
                                      field: 'cancelled_invoiced'
                                  }
                              },
                              cancelled_invoiced_total: {
                                  sum: {
                                      field: 'cancelled_invoiced_total'
                                  }
                              }

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
