class PurchaseOrdersIndex < BaseIndex
  material_statuses = PurchaseOrder.material_statuses
  po_statuses = PoRequest.statuses
  statuses = PurchaseOrder.statuses
  payment_request_statuses = PaymentRequest.statuses
  supplier_po_type = PoRequest.supplier_po_types

  define_type PurchaseOrder.all.with_includes do
    field :id
    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }, type: 'integer'
    field :inquiry, value: -> (record) { record.inquiry.to_s }, analyzer: 'substring'
    field :material_status_string, value: -> (record) { record.material_status.to_s }, analyzer: 'substring'
    field :material_status, value: -> (record) { material_statuses[record.material_status] || material_statuses['Material Readiness Follow-Up'] }
    field :po_number, value: -> (record) { record.po_number.to_i }, type: 'integer'
    field :po_number_string, value: -> (record) { record.po_number.to_s }, analyzer: 'substring'
    field :po_status, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :po_status_string, value: -> (record) { record.status || record.metadata_status }, analyzer: 'substring'
    field :po_request_status, value: -> (record) { po_statuses[record.po_request ? record.po_request.status : 'PO Created'] }
    field :po_request_status_string, value: -> (record) { record.po_request ? record.po_request.status : 'PO Created' }, analyzer: 'substring'
    field :po_email_sent, value: -> (record) { record.try(:has_sent_email_to_supplier?) ? true : nil }
    field :supplier_id, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:id) if record.rows.present? }
    field :supplier, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).to_s if record.rows.present? }, analyzer: 'substring'
    field :customer_id, value: -> (record) { record.inquiry.company.try(:id) if record.inquiry.company.present? }, type: 'integer'
    field :customer, value: -> (record) { record.inquiry.company.to_s if record.inquiry.company.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :logistics_owner, value: -> (record) { record.logistics_owner_id if record.logistics_owner.present? }, type: 'integer'
    field :logistics_owner_string, value: -> (record) { record.logistics_owner.full_name.to_s if record.logistics_owner.present? }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.inquiry.company_id if record.inquiry.present? }
    field :company_rating, value: ->(record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:rating) if record.rows.present? }
    field :company_rating, value: ->(record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:rating) if record.rows.present? }
    field :po_date, value: -> (record) { record.metadata['PoDate'].to_date if record.metadata['PoDate'].present? && record.valid_po_date? }, type: 'date'
    field :payment_request_status_key, value: -> (record) { payment_request_statuses[record.payment_request.status] if record.payment_request.present? }, type: 'integer'
    field :payment_request_status, value: -> (record) { payment_request_statuses[record.payment_request.status] if record.payment_request.present? }
    field :payment_request_status_string, value: -> (record) { record.try(:payment_request).try(:status).to_s }, analyzer: 'substring'
    field :followup_date, type: 'date'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :potential_value, value: -> (record) { record.try(:calculated_total) }, type: 'double'
    field :po_type, value: -> (record) { supplier_po_type[record.po_request.supplier_po_type] if record.po_request.present? }
    field :po_type_string, value: -> (record) { record.po_request.supplier_po_type.to_s if record.po_request.present? }, analyzer: 'substring'
    field :line_item, value: -> (record) {record.rows.count if record.rows.present? }, type: 'integer'
    field :overall_margin, value: -> (record) { record.po_request.sales_order.calculated_total_margin_percentage if record.po_request.present? && record.po_request.sales_order.present? }, type: 'integer'
    field :so_number, value: -> (record) { record.po_request.sales_order.order_number if record.po_request.present? && record.po_request.sales_order.present? }, type: 'integer'
    field :so_number_string, value: -> (record) { record.po_request.sales_order.order_number.to_s if record.po_request.present? && record.po_request.sales_order.present? }, analyzer: 'substring'
  end
end
