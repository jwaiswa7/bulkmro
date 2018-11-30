class Services::Overseers::Finders::Products < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
                        super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
                      else
                        super
                      end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query({
                                            multi_match: {
                                                query: query,
                                                operator: 'and',
                                                fields: %w[sku^3 sku_edge name brand category],
                                                minimum_should_match: '100%'
                                            }
                                        })

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records
  end

  def manage_failed_skus(query, per, page)
    return [] if query.blank?
    query = query[0, 35]

    search_query = {
        multi_match: {
            query: query,
            operator: 'or',
            fields: %w[name mpn^3  ],
        }
    }

    indexed_records = index_klass.query(search_query).page(page).per(per)

    @records = model_klass.where(:id => indexed_records.pluck(:id)).approved.with_includes.reverse
  end


  def model_klass
    Product
  end

end