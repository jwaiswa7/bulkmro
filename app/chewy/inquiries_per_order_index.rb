class InquiriesPerOrderIndex < BaseIndex
  statuses = Inquiry.statuses
  define_type Inquiry.where.not(inside_sales_owner_id: nil).left_outer_joins(:sales_orders).with_includes.select('inquiries.*,sales_orders.*') do
    field :id, value: -> (record) { record.id }, type: 'integer'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }
    field :status_key, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :subject, analyzer: 'substring'
    field :inquiry_number, value: -> (record) { record.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry_number.to_s }, analyzer: 'substring'
    field :sales_orders_id, value: -> (record) { record.order_number if record.order_number.present? }, analyzer: 'substring'
    field :calculated_total, value: -> (record) { record.sales_orders.map(&:calculated_total).last if record.sales_orders.present? }, type: 'double'
    field :inside_sales_owner_id, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.outside_sales_owner.id if record.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.outside_sales_owner_id }
    field :margin_percentage, value: -> (record) { record.sales_orders.map(&:calculated_total_margin_percentage).last if record.sales_orders.present?  }, type: 'double'
    field :margin, value: -> (record) { record.sales_orders.map(&:calculated_total_margin).last if record.sales_orders.present?  }, type: 'double'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
  end
end
