class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.manager?
      super.filter({terms: {created_by_id: current_overseer.self_and_descendant_ids}})
      super.filter({terms: {inside_sales_executive: current_overseer.self_and_descendant_ids}})
      super.filter({terms: {outside_sales_executive: current_overseer.self_and_descendant_ids}})
    else
      super
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    # if range_filters.present?
    #   indexed_records = range_query(indexed_records)
    # end
    #indexed_records = indexed_records.query({range: {created_at:{gte:'2018-05-10', lte: '2018-05-20'} }})
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query({
                                            multi_match: {
                                                query: query_string,
                                                operator: 'and',
                                                fields: index_klass.fields
                                            }
                                        })

    if current_overseer.present? && !current_overseer.manager?
      indexed_records = indexed_records.filter({terms: {created_by_id: current_overseer.self_and_descendant_ids}})
      indexed_records = indexed_records.filter({terms: {inside_sales_executive: current_overseer.self_and_descendant_ids}})
      indexed_records = indexed_records.filter({terms: {outside_sales_executive: current_overseer.self_and_descendant_ids}})
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    # indexed_records = indexed_records.query({range: {created_at:{gte:'2018-05-10', lte: '2018-05-20'} }})
    indexed_records
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end