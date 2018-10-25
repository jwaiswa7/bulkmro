class Services::Customers::Finders::SalesQuotes < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.present?
                        super.filter(filter_by_owner(current_contact.id))
                      else
                        super
                      end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[inquiry_number_string^3 sales_person  line_items valid_upto_s status_string quote_total ]}})

    if current_contact.present? && !current_contact.manager?
      indexed_records = indexed_records.filter(filter_by_owner(current_contact.id))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def model_klass
    SalesQuote
  end
end