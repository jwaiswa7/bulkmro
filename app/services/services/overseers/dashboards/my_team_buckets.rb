class Services::Overseers::Dashboards::MyTeamBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, overseers, params)
    @inquiry_records = all_indexed_records.aggregations['inside_sales_owners']['buckets']
    @overseers = overseers
  end

  def call
    @inquiry_records = format_array_to_hash(@inquiry_records)
    inside_sales_owners = @overseers
    if @inside_sales_owner_id.present?
      inside_sales_owners = inside_sales_owners.where(id: @inside_sales_owner_id)
    end
    records = []
    inside_sales_owners.each do |is_owner|
      records << {
          name: is_owner.full_name,
          id: is_owner.id,

      }
    end
    records
  end

  def format_array_to_hash(array_data)
    hash_data, final_hash = {}
    array_data.map { |record| hash_data[record['key']] = record['statuses']['buckets'] }
    hash_data
  end

  attr_accessor :all_indexed_records, :inside_sales_owner_id, :overseers
end