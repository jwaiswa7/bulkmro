class Services::Overseers::Finders::Inquiries < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    if overseer_ids.present?
      super.filter({terms: {created_by_id: overseer_ids}.compact })
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

    indexed_records = indexed_records.filter({terms: {created_by_id: overseer_ids}}) if overseer_ids.present?
    indexed_records
  end

  def sort_definition
    {:inquiry_number => :desc}
  end

  def model_klass
    Inquiry
  end
end