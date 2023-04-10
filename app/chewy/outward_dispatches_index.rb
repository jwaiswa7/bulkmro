class OutwardDispatchesIndex < BaseIndex
  statuses = OutwardDispatch.statuses
  define_type OutwardDispatch.all do
    field :id
    field :inquiry_number, value: -> (record) { record.sales_invoice.inquiry.inquiry_number if record.sales_invoice.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.sales_invoice.inquiry.inquiry_number.to_s if record.sales_invoice.inquiry.present? }, analyzer: 'substring'
    field :sales_order_number, value: -> (record) { record.sales_invoice.sales_order.order_number if record.sales_invoice.sales_order.present? }, type: 'long'
    field :sales_order_number_string, value: -> (record) { record.sales_invoice.sales_order.order_number.to_s if record.sales_invoice.sales_order.present? }, analyzer: 'substring'
    field :sales_invoice_number, value: -> (record) { record.sales_invoice.invoice_number if record.sales_invoice.present? }, type: 'integer'
    field :sales_invoice_number_string, value: -> (record) { record.sales_invoice.invoice_number.to_s if record.sales_invoice.present? }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.sales_invoice.inquiry.company_id if record.sales_invoice.present? }
    field :company, value: -> (record) { record.sales_invoice.inquiry.company.to_s if record.sales_invoice.present? }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :dispatch_mail_sent_to_the_customer, value: -> (record) { record.dispatch_mail_sent_to_the_customer ? record.dispatch_mail_sent_to_the_customer : false }
    field :material_delivered_mail_sent_to_customer, value: -> (record) { record.material_delivered_mail_sent_to_customer ? record.material_delivered_mail_sent_to_customer : false }
    field :created_at, type: 'date'
    field :material_dispatch_date, type: 'date'
    field :expected_date_of_delivery, type: 'date'
    field :material_delivery_date, type: 'date'
    field :material_delivery_status, value: ->(record) { (statuses[record.get_material_delivery_status].to_i if record.get_material_delivery_status.present?) }, type: 'integer'
    field :material_delivery_status_string, value: ->(record) { (record.get_material_delivery_status.downcase if record.get_material_delivery_status.present?) }, analyzer: 'substring'
    field :logistics_owner_id, value: -> (record) { record.sales_invoice.inquiry.company.logistics_owner_id if record.sales_invoice.present? && record.sales_invoice.inquiry.present? && record.sales_invoice.inquiry.company.present? }, type: 'integer'
    field :logistics_owner, value: -> (record) { record.sales_invoice.inquiry.company.logistics_owner&.name if record.sales_invoice.present? && record.sales_invoice.inquiry.present? && record.sales_invoice.inquiry.company.present? }, analyzer: 'substring'
    field :is_owner_id, value: -> (record) { record.sales_invoice.inquiry.inside_sales_owner_id if record.sales_invoice.present? && record.sales_invoice.inquiry.present? }, type: 'integer'
    field :is_owner, value: -> (record) { record.sales_invoice.inquiry.inside_sales_owner&.name if record.sales_invoice.present? && record.sales_invoice.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.sales_invoice.inquiry.inside_sales_owner_id if record.sales_invoice.present? && record.sales_invoice.inquiry.present? }, type: 'integer'
    field :outside_sales_executive, value: -> (record) { record.sales_invoice.inquiry.outside_sales_owner_id if record.sales_invoice.present? && record.sales_invoice.inquiry.present? }, type: 'integer'
    field :procurement_operations, value: -> (record) { record.sales_invoice.inquiry.procurement_operations_id if record.sales_invoice.present? && record.sales_invoice.inquiry.present? }, type: 'integer'
  end
end
