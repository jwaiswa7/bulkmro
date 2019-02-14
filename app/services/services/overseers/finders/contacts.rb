

class Services::Overseers::Finders::Contacts < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Contact
  end

  def perform_query(query)
    query = query[0, 35]

    index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[firstname^3 lastname^3 email account inquiry],
          minimum_should_match: '100%'
      }
                      ).order(sort_definition)
  end

  def sort_definition
    { created_at: :asc }
  end
end
