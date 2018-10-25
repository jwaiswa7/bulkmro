class Services::Customers::Finders::SalesOrders < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.present?
                        super.filter(filter_by_value('contact_id',current_contact.id))
                      else
                        super
                      end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query_string)
    query_string = query_string[0, 35]

    indexed_records = index_klass.query({multi_match: {query: query_string, operator: 'and', fields: %w[inquiry_number_string^1 order_number^3 status_string customer_po_number_string company^2 quote_total order_total status_string ]}}).order(sort_definition)

    if current_contact.present?
      indexed_records = indexed_records.filter(filter_by_value('contact_id',current_contact.id))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def model_klass
    SalesOrder
  end
end