class Services::Overseers::Finders::SalesShipments < Services::Overseers::Finders::BaseFinder
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

    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and', fields: %w[shipment_number_s^3 sales_order_id sales_order_number_s^2 status_s inquiry_number_s^4 inside_sales_owner outside_sales_owner shipment_grn packing_remarks] })

    if current_overseer.present? && !current_overseer.allow_inquiries?
      indexed_records = indexed_records.filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    indexed_records
  end

  def sort_definition
    { shipment_number: :desc }
  end

  def model_klass
    SalesShipment
  end
end
