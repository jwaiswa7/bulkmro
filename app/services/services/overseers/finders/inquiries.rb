class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def perform_query(query)
    [prepare_query(query_string), overseer_id_filter(query_string)].compact.reduce(:merge)
  end
  def prepare_query(query)
    index_klass.query({
                          multi_match: {
                              query: query,
                              operator: 'and',
                              fields: index_klass.fields
                          }
                      })
  end
  def overseer_id_filter(query)
    index_klass.filter({term: {created_by_id: 'gaurav'  }})
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end