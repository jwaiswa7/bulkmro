
class Services::Overseers::Statuses::GetSummaryStatusBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, model_klass)
    @all_indexed_records = all_indexed_records
    @model_klass = model_klass
  end

  def call
    default_statuses = model_klass.statuses.values.inject({}){|hash,key| hash[key] = 0; hash}
    indexed_buckets = all_indexed_records.aggregations["statuses"]["buckets"]
    statuses = indexed_buckets.inject({}){|hash, bucket| hash[bucket["key"]] = bucket["doc_count"]; hash}
    total_values = indexed_buckets.inject({}){|hash, bucket| hash[bucket["key"]] = bucket["total_value"]["value"]; hash}
    @indexed_statuses = default_statuses.merge(statuses)
    @indexed_total_values = default_statuses.merge(total_values)
  end

  attr_accessor :indexed_statuses, :all_indexed_records, :model_klass, :indexed_total_values
end