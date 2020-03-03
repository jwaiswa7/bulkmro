class Services::Suppliers::Finders::SupplierRfqs < Services::Suppliers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_company.present?
      super.filter(filter_by_value('supplier_id', current_company.id))
    else
      super
    end
    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    # indexed_records = filter_by_images(indexed_records)
    indexed_records = indexed_records.aggregations(aggregate_by_status('status_key'))

    indexed_records
  end

  def model_klass
    SupplierRfq
  end

  def perform_query(query)
    query = query[0, 35]
    indexed_records = index_klass.query(multi_match: { query: query, operator: 'and', fields: %w[status_string], minimum_should_match: '100%' }).order(sort_definition)

    if @status.present?
      indexed_records = indexed_records.filter(filter_by_value(:status, @status))
    end

    if current_company.present?
      indexed_records = indexed_records.filter(filter_by_value('supplier_id', current_company.id))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    # indexed_records = filter_by_images(indexed_records)
    indexed_records = indexed_records.aggregations(aggregate_by_status('status_key'))
    indexed_records
  end

  def filter_by_images(indexed_records)
    indexed_records = indexed_records.filter(
      term: { "has_images": true },
        )

    indexed_records
  end
end
