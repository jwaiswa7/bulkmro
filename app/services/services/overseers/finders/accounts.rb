class Services::Overseers::Finders::Accounts < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Account
  end

  def all_records
    indexed_records = super

    indexed_records = indexed_records.filter(filter_by_script("doc['outstanding'].value <  0"))

    indexed_records
  end
end
