class Services::Overseers::Finders::MaterialReadinessQueues  < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      super
    end

    #  @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params).joins(:po_request).where("po_requests.status = ?", 20).order("purchase_orders.created_at DESC")
    statuses = ['Material Readiness Follow-Up', 'Inward Dispatch', 'Inward Dispatch: Partial', 'Material Partially Delivered']
    status_values = PurchaseOrder.material_statuses.map{|key,val| if statuses.include?(key); val ;end}.compact
    indexed_records = indexed_records.filter(filter_by_array('material_status', status_values))
    indexed_records = indexed_records.filter(filter_by_value('po_request_present', true))
    indexed_records = indexed_records.filter(filter_by_value('po_email_sent', true))


    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and', fields: %w[ po_number_string inquiry inside_sales_owner outside_sales_owner supplier customer po_status_string po_request_string material_status_string po_type_string so_number_string logistics_owner_string ] })

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end
    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    indexed_records = indexed_records.filter(filter_by_array('material_status', PurchaseOrder.material_statuses.except(:'Material Delivered').values))
    indexed_records = indexed_records.filter(filter_by_value('po_request_present', true))
    indexed_records = indexed_records.filter(filter_by_value('po_email_sent', true))

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records = indexed_records.aggregations(aggregate_by_status('po_status'))
    indexed_records
  end


  def model_klass
    PurchaseOrder
  end
end
