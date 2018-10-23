class Services::Overseers::Finders::PurchaseOrders < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.manager?
                        super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
                      else
                        super
                      end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[po_number^3 inquiry inside_sales_owner outside_sales_owner]}})

    if current_overseer.present? && !current_overseer.manager?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def sort_definition
    {:po_number => :desc}
  end

  def model_klass
    PurchaseOrder
  end
end