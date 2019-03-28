class Services::Overseers::Finders::KraReportBySalesPersons < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = InquiriesPerOrderIndex.all

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = InquiriesPerOrderIndex.query(multi_match: { query: query_string, operator: 'and', fields: %w[inquiry_number_string] })

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def call_base
    non_paginated_records = if query_string.present?
                              perform_query(query_string)
                            else
                              all_records
                            end

    @indexed_records = non_paginated_records.page(page).per(per) if non_paginated_records.present?
    @indexed_records = non_paginated_records if !paginate

#    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes if indexed_records.present?
#    @records = order_by_ids(@indexed_records) if indexed_records.present?
    if @indexed_records.size > 0
      @records = model_klass.find_ordered(indexed_records.pluck(:inquiry_number)).with_includes if @indexed_records.present?
    else
      @records = model_klass.none
    end
  end

  def model_klass
    Inquiry
  end
end
