class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    if current_overseer.present? && !current_overseer.admin?
      super.filter({terms: {created_by_id: current_overseer.self_and_descendant_ids}.compact})
    else
      super
    end
  end

  def perform_query(query_string)
    indexed_records = index_klass.query({
                                            multi_match: {
                                                query: query_string,
                                                operator: 'and',
                                                fields: index_klass.fields
                                            }
                                        })

    indexed_records = indexed_records.filter({terms: {created_by_id: current_overseer.self_and_descendant_ids}}) if current_overseer.present? && !current_overseer.admin?
    indexed_records
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end