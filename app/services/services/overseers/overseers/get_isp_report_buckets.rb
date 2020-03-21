class Services::Overseers::Overseers::GetIspReportBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, params)
    @inquiry_records = all_indexed_records[:inquiry_records].aggregations['inside_sales_owners']['buckets']
    @sales_quote_records = all_indexed_records[:sales_quote_records].aggregations['inside_sales_owners']['buckets']
    @sales_orders_records = all_indexed_records[:sales_orders_records].aggregations['inside_sales_owners']['buckets']
    @purchase_order_records = all_indexed_records[:purchase_order_records].aggregations['inside_sales_owners']['buckets']
    @inside_sales_owner_id = params[:isp_report][:procurement_specialist].to_i if params[:isp_report].present? && params[:isp_report][:procurement_specialist].present?
  end

  def call
    @inquiry_records = format_array_to_hash(@inquiry_records)
    @sales_quote_records = format_array_to_hash(@sales_quote_records)
    @sales_orders_records = format_array_to_hash(@sales_orders_records)
    @purchase_order_records = format_array_to_hash(@purchase_order_records)
    inside_sales_owners = Overseer.inside_with_additional_overseers.alphabetical
    if @inside_sales_owner_id.present?
      inside_sales_owners = inside_sales_owners.where(id: @inside_sales_owner_id)
    end
    records = []
    inside_sales_owners.each do |isp_owner|
      records << {
          name: isp_owner.full_name,
          id: isp_owner.id,
          inquiries_count: @inquiry_records[isp_owner.id] || 0,
          sales_quotes_count: @sales_quote_records[isp_owner.id] || 0,
          sales_orders_count: @sales_orders_records[isp_owner.id] || 0,
          purchase_orders_count: @purchase_order_records[isp_owner.id] || 0,
      }
    end
    records
  end

  def format_array_to_hash(array_data)
    hash_data = {}
    array_data.map { |record| hash_data[record['key']] = record['doc_count'] }
    hash_data
  end

  attr_accessor :all_indexed_records, :inside_sales_owner_id
end
