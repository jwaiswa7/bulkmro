class Services::Overseers::Finders::Products < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def model_klass
    Product
  end

  def perform_query(query)
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

    indexed_records = index_klass.query({
                          multi_match: {
                              query: query,
                              operator: 'or',
                              fields: %w[name],
                          }
                      }).page(page).per(per)

    @records = model_klass.where(:id => indexed_records.pluck(:id)).approved.with_includes
  end

end