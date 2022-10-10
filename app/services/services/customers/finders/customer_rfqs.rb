class Services::Customers::Finders::CustomerRfqs < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_company.present?
      super.filter(filter_by_value('account_id', current_company.account_id))
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
    CustomerRfq
  end
end
