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
                              fields: %w[sku name brand category],
                              minimum_should_match: '100%'
                          }
                      })

  end

end