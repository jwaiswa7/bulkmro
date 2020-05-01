class Services::Overseers::Finders::MyTeam < Services::Overseers::Finders::BaseFinder
  def call
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end
    @records = non_paginated_records
  end

  def all_records
    inquiry_indexed_records = InquiriesIndex.all
    inquiry_indexed_records.order(sort_definition).filter(filter_by_owner(current_overseer.self_and_descendant_ids))
    inquiry_indexed_records.aggregations(aggregate_by_isp_with_status)
  end

  def model_klass
    Dashboard
  end
end
