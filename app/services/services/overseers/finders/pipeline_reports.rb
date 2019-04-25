class Services::Overseers::Finders::PipelineReports < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      super
    end

    indexed_records = aggregation_pipeline_report(indexed_records)

    # ISP 84
    # SM  Lavanya 128
    #     Madan 56
    #     Devang 152
    # BH  Ved 55
    # C   Cummins 4
    #
    # start_at = Date.new(2019, 03, 01).strftime('%Y-%m-%d')
    # end_at = Date.new(2019, 03, 31).strftime('%Y-%m-%d')
    # Inquiry.includes({sales_quotes: [{sales_quote_rows: :supplier}]}).where(
    #     :created_at => start_at.beginning_of_month..end_at.end_of_month).where(
    #     'inside_sales_owner_id IN (?) OR outside_sales_owner_id IN (?)', sales_executive_ids, sales_executive_ids).where(
    #     :company_id => customer_id
    # )

    sales_executives = Overseer.pipeline_executives
    if @pipeline_report_params.present? && @pipeline_report_params['company'].present?
      inquiry_company = @pipeline_report_params['company'].to_i
      indexed_records = indexed_records.filter(filter_by_value('company_id', inquiry_company))
    end
    if @pipeline_report_params.present? && @pipeline_report_params['inside_sales_executive'].present?
      executives = @pipeline_report_params['inside_sales_executive'].to_i
      indexed_records = indexed_records.filter(filter_for_self_and_descendants('inside_sales_owner_id', 'outside_sales_owner_id', [executives]))
    end
    if @pipeline_report_params.present? && @pipeline_report_params['sales_manager'].present?
      sales_executives = sales_executives.map {|o| o if (o.parent_id == @pipeline_report_params['sales_manager'].to_i)}.compact
      indexed_records = indexed_records.filter(filter_for_self_and_descendants('inside_sales_owner_id', 'outside_sales_owner_id', 'sales_manager_id', sales_executives.pluck(:id)))
    end
    if @pipeline_report_params.present? && @pipeline_report_params['business_head'].present?
      sales_executives = sales_executives.map {|o| o if (o.parent.parent_id == @pipeline_report_params['business_head'].to_i || o.parent_id == @pipeline_report_params['business_head'].to_i) if o.parent.present?}.compact
      indexed_records = indexed_records.filter(filter_for_self_and_descendants('inside_sales_owner_id', 'outside_sales_owner_id', 'sales_manager_id', sales_executives.pluck(:id)))
    end

    indexed_records
  end

  def aggregation_pipeline_report(indexed_records)
    if @pipeline_report_params.present? && @pipeline_report_params['date_range'].present?
      from = @pipeline_report_params['date_range'].split('~').first.to_date.strftime('%Y-%m-%d') || Date.new(2019, 01, 01).strftime('%Y-%m-%d')
      to = @pipeline_report_params['date_range'].split('~').last.to_date.strftime('%Y-%m-%d') || Date.new(2019, 01, 31).strftime('%Y-%m-%d')
      date_range = {from: from, to: to, key: 'custom-range'}
    else
      date_range = {from: Date.new(2018, 04, 01).strftime('%Y-%m-%d'), to: Date.today.strftime('%Y-%m-%d'), key: 'custom-range'}
    end

    pipeline_query = {
        'inquiries_over_time': {
            'date_histogram': {
                'field': 'created_at',
                'interval': 'month',
                keyed: true,
                order: {_key: 'desc'}
            },
            aggs: {
                'pipeline': {
                    'terms': {'field': 'status_key'},
                    aggs: {
                        inquiry_value: {
                            sum: {
                                field: 'calculated_total'
                            }
                        }
                    }
                },
                'sum_monthly_sales': {
                    'sum_bucket': {
                        'buckets_path': 'pipeline>inquiry_value'
                    }
                }
            }
        },
        'summary_row': {
            'terms': {'field': 'status_key'},
            aggs: {
                statuswise_inquiry_summary: {
                    sum: {
                        field: 'calculated_total'
                    }
                }
            }
        },
        'summary_row_total': {
            'sum_bucket': {
                'buckets_path': 'summary_row>statuswise_inquiry_summary'
            }
        }
    }

    indexed_records = indexed_records.aggregations(
      'pipeline_filter': {
          'date_range': {
              'field': 'created_at',
              'format': 'yyyy-MM-dd',
              'ranges': [
                  date_range
              ],
              'keyed': 'true'
          },
          'aggs': pipeline_query
      }
    )
    indexed_records
  end

  def model_klass
    Inquiry
  end
end
