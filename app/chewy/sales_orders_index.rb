class SalesOrdersIndex < BaseIndex
  statuses = SalesOrder.statuses
  remote_statuses = SalesOrder.remote_statuses
  define_type SalesOrder.all.with_includes do
    field :id, type: 'integer'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }
    field :remote_status_string, value: -> (record) { record.remote_status.to_s }, analyzer: 'substring'
    field :remote_status, value: -> (record) { remote_statuses[record.remote_status] }
    # field :calculated_total, value: -> (record) { record.calculated_total.to_i if record.calculated_total.present? }
    # field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inside_sales_owner.present? }
    # field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    # field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.outside_sales_owner.present? }
    # field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    # field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    # field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    # field :company, value: -> (record) { record.company.to_s }, analyzer: 'substring'
    # field :account, value: -> (record) { record.account.to_s }, analyzer: 'substring'
    # field :contact, value: -> (record) { record.contact.to_s }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :sent_at, type: 'date'
    field :created_by_id
    field :updated_by_id, value: -> (record) { record.updated_by.to_s }, analyzer: 'letter'
  end

  def self.fields
    [:status, :status_string, :remote_status_string, :remote_status, :inside_sales_owner, :outside_sales_owner, :inside_sales_executive, :outside_sales_executive, :sent_at, :created_by_id]
  end
end