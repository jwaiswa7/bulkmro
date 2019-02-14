class Services::Overseers::Finders::SmartQueues < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      super.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    else
      super
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = filter_not(indexed_records)

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
      multi_match: {
          query: query_string,
          operator: 'and',
          fields: index_klass.fields
      }
                                        )

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = filter_not(indexed_records)

    indexed_records.order(sort_definition)
  end

  def filter_not(indexed_records)
    indexed_records = indexed_records.query(
      bool: {
          must_not: [
              {
                  terms: { status: self.sq_filtered_statuses },
              }
          ]
      }
    )
  end

  def model_klass
    Inquiry
  end

  def sort_definition
    [{ priority: :desc }, { quotation_followup_date: :asc }, { calculated_total: :desc }]
  end

  def sq_filtered_statuses
    [Inquiry.statuses[:'Lead by O/S'], Inquiry.statuses[:'Order Lost'], Inquiry.statuses[:'Regret']]
  end
end
