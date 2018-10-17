class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.manager?
                        if current_overseer.inside?
                          super.filter({terms: {inside_sales_owner_id: current_overseer.self_and_descendant_ids}})
                        elsif current_overseer.outside?
                          super.filter({terms: {outside_sales_owner_id: current_overseer.self_and_descendant_ids}})
                        end
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
      indexed_records = indexed_records.filter(
          if current_overseer.inside?
            {terms: {inside_sales_owner_id: current_overseer.self_and_descendant_ids}}
          elsif current_overseer.outside?
            {terms: {outside_sales_owner_id: current_overseer.self_and_descendant_ids}}
          end
      )
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