class Services::Customers::Finders::CustomerProducts < Services::Customers::Finders::BaseFinder
  def call
    case @stock
      when "in_stock"
        @search_filters.push({name: "stock", search: {value: 1 }})
      when "out_of_stock"
        @search_filters.push({name: "stock", search: {value: 0 }})
    end
    # search for published state
    @search_filters.push({name: "published", search: {value: @published ? 1: 0 }}) unless @published.nil?
    
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

    indexed_records = index_klass.query(
      multi_match: {
        query: query,
        operator: 'and',
        fields: %w[brand^4 category^4 name^3 sku^3],
        minimum_should_match: '100%'
      }
    )

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
