
class Services::Overseers::Statuses::GetSummaryStatusBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, model_klass)
    @all_indexed_records = all_indexed_records
    @model_klass = model_klass
  end

  def call
    statuses = {}
    default_statuses = model_klass.statuses.values.inject({}){|hash,key| hash[key] = 0; hash}
    indexed_buckets = all_indexed_records.aggs["statuses"]["buckets"]
    indexed_buckets.map{|bucket| statuses[bucket["key"]] = bucket["doc_count"]}
    @indexed_statuses = default_statuses.merge(statuses)
  end

  attr_accessor :indexed_statuses, :all_indexed_records, :model_klass
end