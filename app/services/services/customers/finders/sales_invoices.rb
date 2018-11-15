class Services::Customers::Finders::SalesInvoices < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.account_manager?
                        super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)).merge(filter_by_value("legacy", false)))
                        #super.filter(filter_by_value('account_id',current_contact.account.id))
                      else
                        super.filter(filter_by_array('company_id', current_contact.companies.pluck(:id)).merge(filter_by_value("legacy", false)))
                      end


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

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[invoice_number^3 sales_order_id sales_order_number status inquiry_number]}})

    # if current_overseer.present? && !current_overseer.allow_inquiries?
    #   indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    # end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def sort_definition
    {:invoice_number => :desc}
  end

  def model_klass
    SalesInvoice
  end
end