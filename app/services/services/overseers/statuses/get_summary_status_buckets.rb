class Services::Overseers::Statuses::GetSummaryStatusBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, model_klass, custom_status: nil, main_summary_status: [])
    if all_indexed_records.class == 'Array'.constantize && all_indexed_records.length > 1
      @followup_records = all_indexed_records[0]
      @committed_date_records = all_indexed_records[1]
      @indexed_buckets = (@followup_records.count > 0) ? @followup_records.aggregations['statuses']['buckets'] : []
      
      @indexed_buckets = @indexed_buckets.push(@committed_date_records.aggregations['statuses']['buckets']).flatten
    else
      @all_indexed_records = all_indexed_records
      @indexed_buckets = (all_indexed_records.count > 0) ? all_indexed_records.aggregations['statuses']['buckets'] : []
      #@indexed_buckets_without_tax = (all_indexed_records.count > 0) ? all_indexed_records.aggregations['statuses_without_tax']['buckets'] : []
    end
    
    @model_klass = model_klass
    @custom_status = custom_status
    @main_summary_status = main_summary_status.values if main_summary_status.present?
  end

  def call

    if custom_status.present?
      model_statuses = model_klass.send(custom_status.pluralize)
    else
      model_statuses = model_klass.statuses
    end

    if main_summary_status.present?
      main_statuses = indexed_buckets.inject({}) { |hash, bucket| hash[bucket['key']] = bucket['doc_count'] if main_summary_status.include?(bucket['key'].to_i); hash }
    end

    default_statuses = model_statuses.values.inject({}) { |hash, key| hash[key] = 0; hash }
    statuses = indexed_buckets.inject({}) { |hash, bucket| hash[bucket['key']] = bucket['doc_count']; hash }
    total_values = indexed_buckets.inject({}) { |hash, bucket| hash[bucket['key']] = bucket['total_value']['value']; hash }
    total_values_without_tax = indexed_buckets_without_tax.inject({}) { |hash, bucket| hash[bucket['key']] = bucket['total_value']['value']; hash }

    @indexed_statuses = default_statuses.merge(statuses)
    @indexed_main_summary_statuses = main_statuses
    @indexed_total_values = default_statuses.merge(total_values)
    @indexed_total_values_without_tax = default_statuses.merge(total_values_without_tax)
  end

  attr_accessor :indexed_statuses, :indexed_main_summary_statuses, :all_indexed_records, :model_klass, :indexed_total_values, :custom_status, :indexed_buckets, :main_summary_status, :indexed_buckets_without_tax, :indexed_total_values_without_tax
end
