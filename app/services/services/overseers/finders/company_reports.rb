class Services::Overseers::Finders::CompanyReports < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = index_klass.limit(model_klass.count).order(sort_definition)

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records
  end

  def perform_query(query_string)
    indexed_records = index_klass.query(
        multi_match: {
            query: query_string,
            operator: 'and',
            fields: %w[name account]
        }
    ).order(sort_definition)


    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end
    indexed_records
  end

  def model_klass
    Company
  end

  def index_klass
    'CompanyReportsIndex'.constantize
  end

  def sort_definition
    { live_inquiries: :desc }
  end
end

