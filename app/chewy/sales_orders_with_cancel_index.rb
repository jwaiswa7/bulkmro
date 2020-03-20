class SalesOrdersWithCancelIndex < BaseIndex
  define_type SalesOrder.with_includes do
    witchcraft!
    field :id, type: 'integer'
    field :order_number, value: -> (record) { record.order_number }, type: 'long'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.present? && record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id if record    .inquiry.present? }
    field :mis_date, value: -> (record) { record.mis_date }, type: 'date'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
