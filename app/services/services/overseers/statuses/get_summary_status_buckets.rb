class Services::Overseers::Statuses::GetSummaryStatusBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, model_klass, custom_status: nil)
    if all_indexed_records.length > 1
      @followup_records = all_indexed_records[0]
      @committed_date_records = all_indexed_records[1]
      @indexed_buckets = @followup_records.aggregations['statuses']['buckets']
      @indexed_buckets = @indexed_buckets.push(@committed_date_records.aggregations['statuses']['buckets']).flatten
    else
      @all_indexed_records = all_indexed_records
      @indexed_buckets = all_indexed_records.aggregations['statuses']['buckets']
    end
    @model_klass = model_klass
    @custom_status = custom_status
  end

  def call
    if custom_status.present?
      model_statuses = model_klass.send(custom_status.pluralize)
    else
      model_statuses = model_klass.statuses
    end
    default_statuses = model_statuses.values.inject({}){ |hash, key| hash[key] = 0; hash }
    statuses = indexed_buckets.inject({}){ |hash, bucket| hash[bucket['key']] = bucket['doc_count']; hash }
    total_values = indexed_buckets.inject({}){ |hash, bucket| hash[bucket['key']] = bucket['total_value']['value']; hash }

    @indexed_statuses = default_statuses.merge(statuses)
    @indexed_total_values = default_statuses.merge(total_values)
  end

  attr_accessor :indexed_statuses, :all_indexed_records, :model_klass, :indexed_total_values, :custom_status, :indexed_buckets
end
