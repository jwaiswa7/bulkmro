class PaymentRequestsIndex < BaseIndex
  statuses = PaymentRequest.statuses
  request_owners = PaymentRequest.request_owners

  define_type PaymentRequest.all do
    field :id, type: 'integer'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :request_owner_string, value: -> (record) { record.request_owner }, analyzer: 'substring'
    field :request_owner, value: -> (record) { request_owners[record.request_owner] }, type: 'integer'
    field :status, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :due_date, value: -> (record) { record.due_date }, type: 'date'
    field :updated_at_by_comment, value: -> (record) { record.last_comment.created_at if record.last_comment.present? }, type: 'date'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
