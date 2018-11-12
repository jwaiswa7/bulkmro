class Services::Overseers::Finders::Products < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def model_klass
    Product
  end

  def perform_query(query)
    query = query[0, 35]

    index_klass.query({
                          multi_match: {
                              query: query,
                              operator: 'and',
                              fields: %w[sku^3 sku_edge name brand category],
                              minimum_should_match: '100%'
                          }
                      })

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

end