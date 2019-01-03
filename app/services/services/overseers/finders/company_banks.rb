class Services::Overseers::Finders::CompanyBanks < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def model_klass
    CompanyBank
  end

  def perform_query(query)
    query = query[0, 35]

    index_klass.query({
                          multi_match: {
                              query: query,
                              operator: 'and',
                              fields: %w[name^3 account_number company beneficiary_email],
                              minimum_should_match: '100%'
                          }
                      }).order(sort_definition)
  end

  def sort_definition
    {:created_at => :asc}
  end
end