class SalesInvoicesIndex < BaseIndex
  statuses = SalesInvoice.statuses
  opportunity_type = Inquiry.opportunity_types

  index_scope SalesInvoice.all.with_includes 
    field :id, type: 'integer'
    field :sales_order_id, value: -> (record) { record.sales_order.id if record.sales_order.present? }
    field :sales_order_number, value: -> (record) { record.sales_order.order_number.to_i if record.sales_order.present? }, type: 'long'
    field :invoice_number, value: -> (record) { record.invoice_number.to_i }, type: 'integer'
    field :inquiry_present, value: -> (record) { record.inquiry.present? }, type: 'boolean'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :sales_order_number_string, value: -> (record) { record.sales_order.order_number.to_s if record.sales_order.present? }, analyzer: 'substring'
    field :invoice_number_string, value: -> (record) { record.invoice_number.to_s }, analyzer: 'substring'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.inquiry.company.account_id if record.inquiry.present? }, type: 'integer'
    field :account_string, value: -> (record) { record.inquiry.company.account.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.inquiry.company.id if record.inquiry.present? }, type: 'integer'
    field :contact_id, value: -> (record) { record.inquiry.contact_id if record.inquiry.present? }, type: 'integer'
    field :company_string, value: -> (record) { record.inquiry.company.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }, analyzer: 'substring'
    field :status_key, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :legacy, value: -> (record) { record.is_legacy }
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.present? && record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.present? && record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id if record.inquiry.present? }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id if record.inquiry.present? }
    field :billing_contact, value: -> (record) {record.inquiry&.billing_contact.try(:name)}, analyzer: 'substring'
    field :billing_contact_id, value: -> (record) {record.inquiry.billing_contact.id if record.inquiry&.billing_contact.present? }, type: 'integer'
    field :billing_location, value: -> (record) {record.serialized_billing_address.to_multiline_s if record.serialized_billing_address.present?}, analyzer: 'substring'
    field :shipping_contact, value: -> (record) {record.inquiry&.shipping_contact.try(:name)}, analyzer: 'substring'
    field :mis_date, value: -> (record) { record.mis_date }, type: 'date'
    field :created_at, value: ->(record) { record.created_at.to_date if record.created_at.present? }, type: 'date'
    field :updated_at, type: 'date'
    field :cp_created_at_s, value: -> (record) { record.created_at.strftime('%d-%b-%Y').to_s if record.created_at.present? }, analyzer: 'substring'
    field :cp_delivery_date_s, value: -> (record) { record.delivery_date.strftime('%d-%b-%Y').to_s if record.delivery_date.present? }, analyzer: 'substring'
    field :cp_po_number_s, value: -> (record) { record.inquiry.customer_po_number.to_s if record.inquiry.present? && record.inquiry.customer_po_number.present? }, analyzer: 'substring'
    field :cp_order_date_s, value: -> (record) { record.inquiry.customer_order_date.strftime('%d-%b-%Y').to_s if record.inquiry.present? && record.inquiry.customer_order_date.present? }, analyzer: 'substring'
    field :payment_option_id, value: -> (record) { record.sales_order.present? ? record.sales_order.inquiry.present? ? record.sales_order.inquiry.payment_option.present? ? record.sales_order.inquiry.payment_option.id : '' : '' : '' }
    field :potential_value, value: -> (record) { record.try(:calculated_total_with_tax) }, type: 'double'
    field :subtotal_value, value: -> (record) { record.try(:calculated_total) }, type: 'double'
    field :invoice_created_at, value: -> (record) { record.mis_date if record.status != 'Cancelled' }, type: 'date'
    field :is_pod, value: -> (record) {(record.has_attachment? ? 1 : 0) if record.status != 'Cancelled'}, type: 'integer'
    field :regular_pod, value: -> (record) {record.mis_date if !record.has_attachment? && record.inquiry.present? && record.inquiry.opportunity_type != 'route_through' && record.status != 'Cancelled' }, type: 'date'
    field :route_through_pod, value: -> (record) {record.mis_date if !record.has_attachment? && record.inquiry.present? && record.inquiry.opportunity_type == 'route_through' && record.status != 'Cancelled'}, type: 'date'
    field :opportunity_type, value: -> (record) {opportunity_type[record.inquiry.opportunity_type] if record.inquiry.present?}, type: 'integer'
    field :pod_type, value: -> (record) {(record.inquiry.opportunity_type != 'route_through' ? 40 : 70) if record.inquiry.present? && record.status != 'Cancelled' }, type: 'integer'
  
end
