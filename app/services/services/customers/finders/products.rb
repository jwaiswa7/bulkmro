class Services::Customers::Finders::Products < Services::Customers::Finders::BaseFinder

  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.account_manager?
                        super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
                      else
                        super.filter(filter_by_array('company_id', [current_contact.company.id]))
                      end
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def model_klass
    Product
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query({multi_match: {query: query,operator: 'and',fields: %w[sku^3 sku_edge name approved brand category],minimum_should_match: '100%'}}).order(sort_definition)

    if current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
    else
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

end