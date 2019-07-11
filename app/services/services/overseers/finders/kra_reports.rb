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

    indexed_records = aggregation_kra_report(indexed_records)
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
    indexed_records = aggregation_kra_report(indexed_records)
    indexed_records
  end

  def aggregation_kra_report(indexed_records)
    if @kra_report_params.present?
      if @kra_report_params['date_range'].present?
        from = @kra_report_params['date_range'].split('~').first.to_date.strftime('%d-%m-%Y')
        to = @kra_report_params['date_range'].split('~').last.to_date.strftime('%d-%m-%Y')
        date_range = {from: from, to: to, key: 'custom-range'}
      else
        date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
      end
      if @kra_report_params['category'].present?
        if @kra_report_params['category'].include? 'inside'
          terms_field = 'inside_sales_owner_id'
        elsif @kra_report_params['category'].include? 'outside'
          terms_field = 'outside_sales_owner_id'
        else
          terms_field = @kra_report_params['category']
        end
      else
        terms_field = 'inside_sales_owner_id'
      end
    else
      terms_field = 'inside_sales_owner_id'
      date_range = {to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
    end
    indexed_records = indexed_records.aggregations(
      'kra_over_month': {
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
                  'terms': {'field': terms_field, size: 10000},
                  aggs: {
                      invoices_count: {
                          sum: {
                              field: 'invoices_count'
                          }
                      },
                      sales_quote_count: {
                          sum: {
                              field: 'sales_quote_count'
                          }
                      },
                      sales_order_count: {
                          sum: {
                              field: 'sales_order_count'
                          }
                      },
                      expected_order: {
                          sum: {
                              field: 'expected_order'
                          }
                      },
                      order_won: {
                          sum: {
                              field: 'order_won'
                          }
                      },
                      total_quote_value: {
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
                      sku: {
                          sum: {
                              field: 'sku'
                          }
                      },
                      company_key: {
                          cardinality: {
                              field: 'company_key'
                          }
                      },
                      gross_margin_assumed: {
                          sum: {
                              field: 'gross_margin_assumed'
                          }
                      },
                      gross_margin_percentage: {
                          sum: {
                              field: 'gross_margin_percentage'
                          }
                      },
                      gross_margin_actual: {
                          sum: {
                              field: 'gross_margin_actual'
                          }
                      }
                      # inquiry_target_monthly: {
                      #     sum: {
                      #         field: 'inquiry_target_monthly'
                      #     }
                      # }
                  }
              }
          }
      }
      )
    indexed_records
  end

  def model_klass
    if @kra_report_params.present? && @kra_report_params['category'] == 'company_key'
      Company
    else
      Inquiry
    end
  end

  def index_klass
    'KraReportsIndex'.constantize
  end
end
