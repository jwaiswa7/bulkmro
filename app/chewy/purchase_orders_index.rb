class PurchaseOrdersIndex < BaseIndex
  material_statuses = PurchaseOrder.material_statuses
  material_summary_statuses = PurchaseOrder.material_summary_statuses
  po_statuses = PoRequest.statuses
  statuses = PurchaseOrder.statuses
  payment_request_statuses = PaymentRequest.statuses
  supplier_po_type = PoRequest.supplier_po_types

  index_scope PurchaseOrder.all.with_includes 
    field :id
    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }, type: 'integer'
    field :inquiry, value: -> (record) { record.inquiry.to_s }, analyzer: 'substring'
    field :material_status, value: -> (record) { material_statuses[record.material_status] || material_statuses['Material Readiness Follow-Up'] }
    field :po_number, value: -> (record) { record.po_number.to_i }, type: 'integer'
    field :po_number_string, value: -> (record) { record.po_number.to_s }, analyzer: 'substring'
    field :po_status, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :po_status_string, value: -> (record) { record.status || record.metadata_status }, analyzer: 'substring'
    field :po_request_id, value: -> (record) { record.po_request.present? ? record.po_request.id : 0 }, type: 'integer'
    field :po_request_string, value: -> (record) { record.po_request.present? ? record.po_request.to_s : ''}, analyzer: 'substring'
    field :po_request_status, value: -> (record) { po_statuses[record.po_request ? record.po_request.status : 'Supplier PO Sent'] }
    field :po_request_status_string, value: -> (record) { record.po_request ? record.po_request.status : 'Supplier PO Sent' }, analyzer: 'substring'
    field :po_email_sent, value: -> (record) { record.po_request ? (record.po_request.status == 'Supplier PO Sent' ? true : nil) : nil }
    field :supplier_id, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:id) if record.rows.present? }
    field :supplier, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).to_s if record.rows.present? }, analyzer: 'substring'
    field :customer_id, value: -> (record) { record.inquiry.company.try(:id) if record.inquiry.company.present? }
    field :customer, value: -> (record) { record.inquiry.company.to_s if record.inquiry.company.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :logistics_owner, value: -> (record) { (record.logistics_owner_id.present?) ? record.logistics_owner_id : 0 }
    field :company_id, value: -> (record) { record.inquiry.company_id if record.inquiry.present? }
    field :company_rating, value: ->(record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:rating) if record.rows.present? }
    field :company_rating, value: ->(record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:rating) if record.rows.present? }
    field :po_date, value: -> (record) { record.metadata['PoDate'].to_date if record.metadata['PoDate'].present? && record.valid_po_date? }, type: 'date'
    field :payment_request_status_key, value: -> (record) { payment_request_statuses[record.payment_request.status] if record.payment_request.present? }, type: 'integer'
    field :payment_request_status, value: -> (record) { payment_request_statuses[record.payment_request.status] if record.payment_request.present? }
    field :payment_request_status_string, value: -> (record) { record.try(:payment_request).try(:status).to_s }, analyzer: 'substring'

    field :followup_date, type: 'date'
    field :committed_date, value: ->(record) { record.po_request.inquiry.customer_committed_date if record.po_request.present? }, type: 'date'
    field :followup_status, value: ->(record) { (material_summary_statuses[record.get_followup_status].to_i if record.get_followup_status.present?) }, type: 'integer'
    field :followup_status_string, value: ->(record) { (record.get_followup_status.downcase if record.get_followup_status.present?) }, analyzer: 'substring'
    field :committed_date_status, value: ->(record) { (material_summary_statuses[record.get_committed_date_status].to_i if record.get_committed_date_status.present?) }, type: 'integer'
    field :committed_date_status_string, value: ->(record) { (record.get_committed_date_status.downcase if record.get_committed_date_status.present?) }, analyzer: 'substring'

    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :potential_value, value: -> (record) { record.try(:calculated_total) }, type: 'double'
    field :po_type, value: -> (record) { supplier_po_type[record.po_request.supplier_po_type] if record.po_request.present? }
    field :line_item, value: -> (record) {record.rows.count if record.rows.present? }, type: 'integer'
    field :overall_margin, value: -> (record) { record.po_request.sales_order.calculated_total_margin_percentage if record.po_request.present? && record.po_request.sales_order.present? }, type: 'integer'
    field :po_request_present, value: -> (record) { record.po_request_present? }
    field :expected_delivery_date, value: -> (record) { record.revised_supplier_delivery_date}, type: 'date'
    field :latest_comment, value: -> (record) { record.last_comment.present? ? record.last_comment.created_at : Date.today }, type: 'date'

end
