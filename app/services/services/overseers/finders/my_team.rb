class Services::Overseers::Finders::MyTeam < Services::Overseers::Finders::BaseFinder
  def call
    @records = all_records
  end

  def all_records
    InquiriesIndex.all.order(sort_definition)
        .filter(filter_by_owner(current_overseer.self_and_descendant_ids))
        .aggregations(aggregate_by_isp_with_status)
  end
end
