class Services::Overseers::Finders::Contacts < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Contact
  end

  def all_records
    indexed_records = index_klass.all.order(sort_definition)

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end


  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[firstname^3 lastname^3 email account inquiry],
          minimum_should_match: '100%'
      }
                      ).order(sort_definition)
    
    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def sort_definition
    { created_at: :asc }
  end
end
