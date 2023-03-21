class Services::Overseers::Finders::Tasks < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Task
  end

  def all_records
    indexed_records = if current_overseer.present? && !current_overseer.allow_inquiries?
      TasksIndex.all.filter(filter_by_array_or_value('assignees' , 'created_by_id', current_overseer.self_and_descendant_ids )).order(sort_definition)
   else
    TasksIndex.all.order(sort_definition)
   end
    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end

  def perform_query(query)
    query = query[0, 35]
    indexed_records = index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[company_name task_id]
      }
    )

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end


    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records
  end
end
