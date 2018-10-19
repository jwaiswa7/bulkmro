class Services::Overseers::Finders::SalesOrders < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def filter_by_owner(ids)
    {
        bool: {
            should: [
                {
                    terms: {inside_sales_executive: ids},
                },
                {
                    terms: {outside_sales_executive: ids}
                }
            ],
            minimum_should_match: 1,
        },

    }
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

    # if range_filters.present?
    #   indexed_records = range_query(indexed_records)
    # end
    #indexed_records = indexed_records.query({range: {created_at:{gte:'2018-05-10', lte: '2018-05-20'} }})
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[order_number^3 status_string remote_status_string updated_by_id quote_total order_total ]}})

    if current_overseer.present? && !current_overseer.manager?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    # indexed_records = indexed_records.query({range: {created_at:{gte:'2018-05-10', lte: '2018-05-20'} }})
    indexed_records
  end


  def model_klass
    SalesOrder
  end
end