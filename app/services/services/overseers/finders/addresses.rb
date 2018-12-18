class Services::Overseers::Finders::Addresses < Services::Overseers::Finders::BaseFinder

  def call
    call_base
  end

  def all_records
    indexed_records = super

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

    index_klass.query({
                          multi_match: {
                              query: query,
                              operator: 'and',
                              fields: %w[id state_name^3 city_name^3 gst^3],
                              minimum_should_match: '100%'
                          }
                      }).order(sort_definition)
  end

  def model_klass
    Address
  end

end