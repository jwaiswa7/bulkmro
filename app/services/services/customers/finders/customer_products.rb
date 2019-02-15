class Services::Customers::Finders::CustomerProducts < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_company.present?
      super.filter(filter_by_value('company_id', current_company.id))
    else
      super
    end


    if @custom_filters.present?
      indexed_records = indexed_records.filter(
        terms: {
            tags: @custom_filters['tags']
        }
                                                 )
      indexed_records
    end
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    # indexed_records = filter_by_images(indexed_records)

    indexed_records
  end

  def model_klass
    CustomerProduct
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(multi_match: { query: query, operator: 'and', fields: %w[sku^3 name brand category], minimum_should_match: '100%' }).order(sort_definition)

    if current_company.present?
      indexed_records = indexed_records.filter(filter_by_value('company_id', current_company.id))
    end

    if @custom_filters.present?
      indexed_records = indexed_records.filter(
        terms: {
            tags: @custom_filters['tags']
        }
                                               )
      indexed_records
    end
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    # indexed_records = filter_by_images(indexed_records)

    indexed_records
  end

  def filter_by_images(indexed_records)
    indexed_records = indexed_records.filter(
      term: { "has_images": true },
                                             )

    indexed_records
  end
end
