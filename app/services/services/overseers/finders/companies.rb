class Services::Overseers::Finders::Companies < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Company
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query({
                                            multi_match: {
                                                query: query,
                                                operator: 'and',
                                                fields: %w[name],
                                                minimum_should_match: '100%'
                                            }
                                        })

    indexed_records
  end
end