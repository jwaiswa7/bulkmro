class Services::Overseers::Dashboards::MyTeamBuckets < Services::Shared::BaseService
  def initialize(all_indexed_records, overseers, params)
    @inquiry_records = all_indexed_records.aggregations['inside_sales_owners']['buckets']
    @overseers = overseers
  end

  def call
    @inquiry_records = format_array_to_hash(@inquiry_records)
    inside_sales_owners = @overseers
    records = []
    inside_sales_owners.each do |is_owner|
      records << {
          name: is_owner.full_name,
          id: is_owner.id,
          acknowledgement_pending: acknowledgement_pending(@inquiry_records, is_owner.id),
          preparing_quotation: preparing_quotation(@inquiry_records, is_owner.id),
          follow_up: follow_up(@inquiry_records, is_owner.id),
          awaited_customer_po: awaited_customer_po(@inquiry_records, is_owner.id),
          pending_account_approval: pending_account_approval(@inquiry_records, is_owner.id)
      }
    end
    records
  end

  def format_array_to_hash(array_data)
    hash_data = {}
    array_data.map { |record| hash_data[record['key']] = record['statuses']['buckets'].map { |bucket_data| { bucket_data['key'] => bucket_data['doc_count'] } } }
    hash_data
  end

  private

    def acknowledgement_pending(records, is_owner_id)
      records[is_owner_id].present? ? records[is_owner_id].reduce({}, :merge).values_at(*[0]).reduce(:+) : nil
    end

    def preparing_quotation(records, is_owner_id)
      records[is_owner_id].present? ? records[is_owner_id].reduce({}, :merge).values_at(*[0, 2, 3, 12, 16, 4]).compact.reduce(:+) : nil
    end

    def follow_up(records, is_owner_id)
      records[is_owner_id].present? ? records[is_owner_id].reduce({}, :merge).values_at(*[6]).reduce(:+) : nil
    end

    def awaited_customer_po(records, is_owner_id)
      records[is_owner_id].present? ? records[is_owner_id].reduce({}, :merge).values_at(*[13, 14]).compact.reduce(:+) : nil
    end

    def pending_account_approval(records, is_owner_id)
      records[is_owner_id].present? ? records[is_owner_id].reduce({}, :merge).values_at(*[8]).reduce(:+) : nil
    end

    attr_accessor :all_indexed_records, :inside_sales_owner_id, :overseers
end
