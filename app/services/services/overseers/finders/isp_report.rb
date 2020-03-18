class Services::Overseers::Finders::IspReport < Services::Overseers::Finders::BaseFinder
  def call
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end

#     @indexed_records = non_paginated_records.page(page).per(per) if non_paginated_records.present?
#     @indexed_records = non_paginated_records if !paginate
#
# #    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes if indexed_records.present?
# #    @records = order_by_ids(@indexed_records) if indexed_records.present?
#     if @indexed_records.size > 0
#       @records = model_klass.find_ordered(indexed_records.pluck(:id)).with_includes if @indexed_records.present?
#     else
#       @records = model_klass.none
#     end
      @records = non_paginated_records
  end

  def all_records
    inquiry_indexed_records = InquiriesIndex.all
    sales_quotes_indexed_records = SalesOrdersWithCancelIndex.all
    sales_orders_indexed_records = SalesOrdersIndex.all
    purchase_order_indexed_records = PurchaseOrdersIndex.all
    if current_overseer.present? && !current_overseer.allow_inquiries?
      inquiry_indexed_records = inquiry_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      sales_quotes_indexed_records = sales_quotes_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      sales_orders_indexed_records = sales_orders_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      purchase_order_indexed_records = purchase_order_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      inquiry_indexed_records = inquiry_indexed_records.order(sort_definition)
      sales_quotes_indexed_records = sales_quotes_indexed_records.order(sort_definition)
      sales_orders_indexed_records = sales_orders_indexed_records.order(sort_definition)
      purchase_order_indexed_records = purchase_order_indexed_records.order(sort_definition)
    end
    if @isp_report_params.present?
      date_range = @isp_report_params["date_range"].split('~')

      if !date_range.empty?
        inquiry_indexed_records = date_range_query(inquiry_indexed_records, date_range)
        sales_quotes_indexed_records = date_range_query(sales_quotes_indexed_records, date_range)
        sales_orders_indexed_records = date_range_query(sales_orders_indexed_records, date_range)
        purchase_order_indexed_records = date_range_query(purchase_order_indexed_records, date_range)
      elsif @isp_report_params['procurement_specialist'].present?
        inquiry_indexed_records = inquiry_indexed_records.filter(filter_by_value('inside_sales_owner_id', @isp_report_params['procurement_specialist'].to_i))
        sales_quotes_indexed_records = sales_quotes_indexed_records.filter(filter_by_value('inside_sales_owner_id', @isp_report_params['procurement_specialist'].to_i))
        sales_orders_indexed_records = sales_orders_indexed_records.filter(filter_by_value('inside_sales_owner_id', @isp_report_params['procurement_specialist'].to_i))
        purchase_order_indexed_records = purchase_order_indexed_records.filter(filter_by_value('inside_sales_owner_id', @isp_report_params['procurement_specialist'].to_i))

      end
    end
    inquiry_indexed_records = inquiry_indexed_records.aggregations(aggregate_by_isp)
    sales_quotes_indexed_records = sales_quotes_indexed_records.aggregations(aggregate_by_isp)
    sales_orders_indexed_records = sales_orders_indexed_records.aggregations(aggregate_by_isp)
    purchase_order_indexed_records = purchase_order_indexed_records.aggregations(aggregate_by_isp)

    {
      inquiry_records: inquiry_indexed_records,
      sales_quote_records: sales_quotes_indexed_records,
      sales_orders_records: sales_orders_indexed_records,
      purchase_order_records: purchase_order_indexed_records
    }
  end

  def perform_query(query_string)
    inquiry_indexed_records = InquiriesIndex.query(multi_match: { query: query_string, operator: 'and', fields: %w[inside_sales_owner] })
    sales_quotes_indexed_records = SalesOrdersWithCancelIndex.query(multi_match: { query: query_string, operator: 'and', fields: %w[inside_sales_owner] })
    sales_orders_indexed_records = SalesOrdersIndex.query(multi_match: { query: query_string, operator: 'and', fields: %w[inside_sales_owner] })
    purchase_order_indexed_records = PurchaseOrdersIndex.query(multi_match: { query: query_string, operator: 'and', fields: %w[inside_sales_owner] })
    if current_overseer.present? && !current_overseer.allow_inquiries?
      inquiry_indexed_records = inquiry_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      sales_quotes_indexed_records = sales_quotes_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      sales_orders_indexed_records = sales_orders_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
      purchase_order_indexed_records = purchase_order_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      inquiry_indexed_records = inquiry_indexed_records.order(sort_definition)
      sales_quotes_indexed_records = sales_quotes_indexed_records.order(sort_definition)
      sales_orders_indexed_records = sales_orders_indexed_records.order(sort_definition)
      purchase_order_indexed_records = purchase_order_indexed_records.order(sort_definition)
    end

    if @isp_report_params.present?
      date_range = @isp_report_params["date_range"].split('~')
      if !date_range.empty?
        inquiry_indexed_records = date_range_query(inquiry_indexed_records, date_range)
        sales_quotes_indexed_records = date_range_query(sales_quotes_indexed_records, date_range)
        sales_orders_indexed_records = date_range_query(sales_orders_indexed_records, date_range)
        purchase_order_indexed_records = date_range_query(purchase_order_indexed_records, date_range)
      end
    end

    inquiry_indexed_records = inquiry_indexed_records.aggregations(aggregate_by_isp)
    sales_quotes_indexed_records = sales_quotes_indexed_records.aggregations(aggregate_by_isp)
    sales_orders_indexed_records = sales_orders_indexed_records.aggregations(aggregate_by_isp)
    purchase_order_indexed_records = purchase_order_indexed_records.aggregations(aggregate_by_isp)

    {
        inquiry_records: inquiry_indexed_records,
        sales_quote_records: sales_quotes_indexed_records,
        sales_orders_records: sales_orders_indexed_records,
        purchase_order_records: purchase_order_indexed_records
    }
  end

  def date_range_query(indexed_records, date_range)
    if !date_range.empty?
      indexed_records.query(
        range: {
          :"created_at" => {
              "time_zone": "+05:30",
              gte: date_range[0].strip.to_date.beginning_of_day,
              lte: date_range[1].strip.to_date.end_of_day
          }
        }
      )
    end
  end

  def model_klass
    Inquiry
  end
end
