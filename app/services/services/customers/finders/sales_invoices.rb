class Services::Customers::Finders::SalesInvoices < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records =  if current_contact.present? && current_company.present?
                         super.filter(filter_by_value('company_id', current_company.id).merge(filter_by_value('contact_id', current_contact.id)))
                       elsif current_company.present?
                         super.filter(filter_by_value('company_id', current_company.id))
                         # super.filter(filter_by_value('account_id',current_contact.account.id))
                         # elsif current_contact.account_manager?
                         #   super.filter(filter_by_array('company_id', current_contact.account.companies.pluck(:id)))
                       else
                         super
                       end

    indexed_records = indexed_records.query(
        range: {
            "created_at": {
                gte: Date.new(2018, 04, 01),
                lte: Date.today
            }
        }
    )
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records = indexed_records.filter(filter_by_value('inquiry_present', true))

    indexed_records
  end

  def perform_query(query_string)
    query_string = query_string[0, 35]

    indexed_records = index_klass.query(multi_match: {query: query_string, operator: 'and', fields: %w[cp_created_at_s cp_delivery_date_s cp_po_number_s status_s cp_order_date_s invoice_number_string^5 inquiry_number_string^4 sales_order_number_string^3 status_s outside_sales_owner^2 inside_sales_owner^2]}).order(sort_definition)

    # if current_overseer.present? && !current_overseer.allow_inquiries?
    #   indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    # end

    if current_company.present?
      indexed_records = indexed_records.filter(filter_by_value('company_id', current_company.id))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = indexed_records.query(
        range: {
            "created_at": {
                gte: Date.new(2018, 04, 01),
                lte: Date.today
            }
        }
    )
    indexed_records = indexed_records.filter(filter_by_value('inquiry_present', true))

    indexed_records
  end

  def sort_definition
    {invoice_number: :desc}
  end

  def model_klass
    SalesInvoice
  end
end
