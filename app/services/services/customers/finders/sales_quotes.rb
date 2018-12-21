class Services::Customers::Finders::SalesQuotes < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_company.present?
                        super.filter(filter_by_value('company_id', current_company.id))
                        #super.filter(filter_by_value('account_id',current_contact.account.id))
                      elsif current_contact.account_manager?
                        super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
                      else
                        super
                      end

    indexed_records.filter(filter_by_status(only_remote_approved: false))
    indexed_records.filter({bool: {should: [{exists: {field: 'sent_at'}}]}})

    indexed_records = indexed_records.filter(filter_by_value('is_final', true))
    indexed_records = indexed_records.query({
                                                range: {
                                                    :"inquiry_created_at" => {
                                                        gte: Date.new(2018, 04, 01),
                                                        lte: Date.today
                                                    }
                                                }
                                            })

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

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[inquiry_number_string^3 line_items valid_upto_s cp_status_s quote_total inside_sales_owner^2 cp_created_at_s cp_calculated_total_s cp_valid_upto_s cp_status_s cp_valid_upto_s cp_created_at_s cp_po_number_s cp_calculated_total_s cp_quote_id_s cp_subject_s cp_company_s cp_contact_email_s cp_billing_city_s cp_shipping_city_s cp_billing_gst_s cp_shipping_gst_s sales_quote_rows.sku sales_quote_rows.name sales_quote_rows.brand sales_quote_rows.mpn ]}}).order(sort_definition)

    indexed_records.filter({bool: {should: [{exists: {field: 'sent_at'}}]}})

    indexed_records = indexed_records.filter(filter_by_value('is_final', true))
    if current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
    else
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
    end

    if current_contact.present? && !current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_value('contact_id', current_contact.id))
      # indexed_records = indexed_records.filter(filter_by_array('id',current_contact.account.sales_quotes.ids))
    end

    indexed_records.filter(filter_by_status(only_remote_approved: false))
    indexed_records.filter({bool: {should: [{exists: {field: 'sent_at'}}]}})
    indexed_records = indexed_records.query({
                                                range: {
                                                    :"inquiry_created_at" => {
                                                        gte: Date.new(2018, 04, 01),
                                                        lte: Date.today
                                                    }
                                                }
                                            })

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