class Services::Customers::Finders::SalesQuotes < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.account_manager?
                        super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
                      else
                        super.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
                      end

    indexed_records.filter({bool: {should: [{exists: {field: 'sent_at'}}]}})

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end



  def perform_query(query_string)
    query_string = query_string[0, 35]

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[inquiry_number_string^3 line_items valid_upto_s status_string quote_total inside_sales_owner ]}}).order(sort_definition)

    indexed_records.filter({bool: {should: [{exists: {field: 'sent_at'}}]}})
    if current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
    else
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
    end

    if current_contact.present? && !current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_value('contact_id', current_contact.id))
      # indexed_records = indexed_records.filter(filter_by_array('id',current_contact.account.sales_quotes.ids))
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
    SalesQuote
  end
end