class Services::Overseers::Finders::PendingSalesOrders < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.manager?
                        super.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_status(:approval_status, 'pending')).merge(filter_by_status(:legacy_status, 'not_legacy')))
                      else
                        super.filter(filter_by_status(:approval_status, 'pending').merge(filter_by_status(:legacy_status, 'not_legacy')))
                      end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[approval_status order_number^3 status_string remote_status_string updated_by_id quote_total order_total inside_sales_owner outside_sales_owner legacy_status ]}})

    if current_overseer.present? && !current_overseer.manager?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids).merge(filter_by_status(:approval_status, 'pending')).merge(filter_by_status(:legacy_status, 'not_legacy')))
    else
      indexed_records = indexed_records.filter(filter_by_status(:approval_status, 'pending').merge(filter_by_status(:legacy_status, 'not_legacy')))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def model_klass
    SalesOrder
  end
end