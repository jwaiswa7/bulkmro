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
                                                fields: %w[name^4 pan^3 is_pan_valid],
                                                minimum_should_match: '100%'
                                            }
                                        })

    indexed_records
  end
end