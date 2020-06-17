class DeliveryChallansIndex < BaseIndex
  reasons = DeliveryChallans.reasons

  define_type DeliveryChallan.all.with_includes do
    field :id, type: 'integer'
    field :reason_string, value: -> (record) { record.reason.to_s }, analyzer: 'substring'
    field :reason, value: -> (record) { statuses[record.reason] }, analyzer: 'substring'
    field :reason_key, value: -> (record) { statuses[record.reason] }, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s }, analyzer: 'substring'
    field :order_number, value: -> (record) { record.sales_order.order_number.to_i }, type: 'integer'
    field :logistics_owner_id, value: -> (record) { record.inquiry.logistics_owner_id }
    field :logistics_owner_s, value: -> (record) { record.inquiry.logistics_owner.to_s }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.inquiry.company_id }
    field :company, value: -> (record) { record.inquiry.company.to_s }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.inquiry.account_id }
    field :account, value: -> (record) { record.inquiry.account.to_s }, analyzer: 'substring'
    field :billing_contact_id, value: -> (record) { record.inquiry.billing_contact_id }
    field :billing_contact_s, value: -> (record) { record.inquiry.billing_contact.to_s }, analyzer: 'substring'
    field :shipping_contact_id, value: -> (record) { record.inquiry.shipping_contact_id }
    field :shipping_contact_s, value: -> (record) { record.inquiry.shipping_contact.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :created_by_id, value: -> (record) { record.created_by.to_s }, analyzer: 'letter'
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
  end

  def self.fields
    [:reason, :reason_string, :inquiry_number_string, :logistics_owner_s, :company, :account, :billing_contact_s, :shipping_contact_s, :created_by_id]
  end
end
