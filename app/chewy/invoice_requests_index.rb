class InvoiceRequestsIndex < BaseIndex
    statuses = InvoiceRequest.statuses
    define_type InvoiceRequest.all do
      field :id, type: 'integer'
      field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'

      field :sales_order_number_string, value: -> (record) { record.sales_order.order_number.to_s if record.sales_order.present? }, analyzer: 'substring'
      field :status, value: -> (record) { statuses[record.status] }, type: 'integer'
      field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
      field :created_by_id, value: -> (record) { record.created_by_id if record.created_by_id.present? }
      field :updated_by_id, value: -> (record) { record.updated_by_id if record.updated_by_id.present? }
      field :created_by_name, value: -> (record) { record.created_by.name if record.created_by_id.present? }, analyzer: 'substring'
      field :updated_by_name, value: -> (record) { record.updated_by.name if record.updated_by_id.present? }, analyzer: 'substring'
      field :logistics_owner_id, value: -> (record) { record.inquiry.company.logistics_owner_id if record.inquiry.present? }, type: 'integer'
      field :logistics_owner, value: -> (record) { record.inquiry.company.logistics_owner&.name if record.inquiry.present? && record.inquiry.company.present? }, analyzer: 'substring'
      field :purchase_order_owner_id, value: -> (record) { record.purchase_order.logistics_owner_id if record.purchase_order.present? }, type: 'integer'
      field :is_owner_id, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }, type: 'integer'
      field :is_owner, value: -> (record) { record.inquiry.inside_sales_owner&.name if record.inquiry.present? }, analyzer: 'substring'
      field :created_at, type: 'date'
      field :updated_at, type: 'date'
      field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present? }
      field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.present? && record.inquiry.outside_sales_owner.present? }
      field :procurement_operations, value: -> (record) { record.inquiry.procurement_operations_id if record.inquiry.present? && record.inquiry.procurement_operations.present? }
    end
  end
