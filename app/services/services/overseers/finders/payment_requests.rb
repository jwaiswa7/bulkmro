class Services::Overseers::Finders::PaymentRequests < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    PaymentRequest
  end

  def all_records
    indexed_records = super

    if @status.present?
      status_array = []
      if @status == 'Pending'
        statuses = ['Payment Pending', 'Partial Payment Pending']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      elsif @status == 'Completed'
        statuses = ['Payment Made', 'Partial Payment Made']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      elsif @status == 'Rejected'
        statuses = ['Supplier Info: Bank Details Missing', 'Supplier Info: Bank Details Incorrect', 'Supplier Info: PI mismatch', 'Rejected: Others']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      end
      indexed_records = indexed_records.filter(filter_by_array(:status, status_array))
    end
    if @owner_type.present?
      statuses = ['Payment Pending', 'Supplier Info: Bank Details Incorrect', 'Partial Payment Pending']
      status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      indexed_records = indexed_records.filter(filter_by_value(:request_owner, PaymentRequest.request_owners[@owner_type]))
      indexed_records = indexed_records.filter(filter_by_array(:status, status_array))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end
    indexed_records = indexed_records.aggregations(aggregate_by_status('status'))
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(multi_match: { query: query_string, operator: 'and', fields: %w[updated_by_id status_string inquiry_number_string^5 inside_sales_owner outside_sales_owner request_owner_string ] }).order(sort_definition)

    if @status.present?
      status_array = []
      if @status == 'Pending'
        statuses = ['Payment Pending', 'Partial Payment Pending']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      elsif @status == 'Completed'
        statuses = ['Payment Made', 'Partial Payment Made']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      elsif @status == 'Rejected'
        statuses = ['Supplier Info: Bank Details Missing', 'Supplier Info: Bank Details Incorrect', 'Supplier Info: PI mismatch', 'Rejected: Others']
        status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      end
      indexed_records = indexed_records.filter(filter_by_array(:status, status_array))
    end

    if @owner_type.present?
      statuses = ['Payment Pending', 'Supplier Info: Bank Details Incorrect', 'Partial Payment Pending']
      status_array = statuses.map { |status| PaymentRequest.statuses[status]}
      indexed_records = indexed_records.filter(filter_by_value(:request_owner, PaymentRequest.request_owners[@owner_type]))
      indexed_records = indexed_records.filter(filter_by_array(:status, status_array))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end
    indexed_records = indexed_records.aggregations(aggregate_by_status('status'))
    indexed_records
  end
end
