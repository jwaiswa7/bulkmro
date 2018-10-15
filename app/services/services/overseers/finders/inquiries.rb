class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    if @overseers.present?
      index_klass.all.order(sort_definition).filter({terms: {created_by_id: @overseers  }})
    else
      index_klass.all.order(sort_definition)
    end
  end

  def perform_query(query)
    [prepare_query(query_string), overseer_id_filter].compact.reduce(:merge)
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

  def overseer_id_filter
    index_klass.filter({terms: {created_by_id: @overseers  }}) if @overseers.present?
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end