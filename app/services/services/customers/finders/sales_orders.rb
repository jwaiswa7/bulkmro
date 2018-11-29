class Services::Customers::Finders::SalesOrders < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.account_manager?
                        super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
                        #super.filter(filter_by_value('account_id',current_contact.account.id))
                      else
                        super.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
                      end

    indexed_records = indexed_records.query({
                                                range: {
                                                    :"created_at" => {
                                                        gte: Date.new(2018, 04, 01),
                                                        lte: Date.today
                                                    }
                                                }
                                            }).order(sort_definition)
    indexed_records = indexed_records.filter(filter_by_value("approval_status", "approved"))

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

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[inquiry_number_string^1 order_number^3 status_string customer_po_number_string company^2 quote_total order_total remote_status_string ]}}).order(sort_definition)

    indexed_records = indexed_records.filter(filter_by_value("approval_status", "approved"))

    if current_contact.account_manager?
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
    else
      indexed_records = indexed_records.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)))
    end

    indexed_records = indexed_records.query({
                                                range: {
                                                    :"created_at" => {
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
    SalesOrder
  end
end