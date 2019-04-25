class InwardDispatchesIndex < BaseIndex
  material_statuses = PurchaseOrder.material_statuses
  po_statuses = PoRequest.statuses
  statuses = InwardDispatch.statuses
  payment_request_statuses = PaymentRequest.statuses
  supplier_po_type = PoRequest.supplier_po_types

  define_type InwardDispatch.all.with_includes do
    field :id
    field :inquiry_id, value: -> (record) { record.purchase_order.inquiry.id if record.inquiry.present? }
    field :inquiry, value: -> (record) { record.purchase_order.inquiry.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }
    field :status_string, value: -> (record) { record.status.to_s }
    field :po_number, value: -> (record) { record.purchase_order.po_number.to_i }, type: 'integer'
    field :po_number_string, value: -> (record) { record.purchase_order.po_number.to_s }, analyzer: 'substring'
    field :so_number, value: -> (record) { record.sales_order.order_number.to_i }, type: 'integer'
    field :so_number_string, value: -> (record) { record.sales_order.order_number.to_s }, analyzer: 'substring'
    field :supplier_id, value: -> (record) { record.purchase_order.get_supplier(record.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:id) if record.purchase_order.rows.present? }
    field :supplier, value: -> (record) { record.purchase_order.get_supplier(record.purchase_order.rows.first.metadata['PopProductId'].to_i).to_s if record.purchase_order.rows.present? }, analyzer: 'substring'
    field :customer_id, value: -> (record) { record.purchase_order.inquiry.company.try(:id) if record.inquiry.company.present? }
    field :customer, value: -> (record) { record.purchase_order.inquiry.company.to_s if record.inquiry.company.present? }, analyzer: 'substring'
    field :logistics_owner_id, value: -> (record) { record.logistics_owner.id if record.logistics_owner.present? }
    field :po_request_status, value: -> (record) { po_statuses[record.purchase_order.po_request ? record.purchase_order.po_request.status : 'Supplier PO: Created Not Sent'] }
    field :po_request_status_string, value: -> (record) { record.purchase_order.po_request ? record.purchase_order.po_request.status : 'Supplier PO: Created Not Sent' }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.purchase_order.inquiry.company_id if record.inquiry.present? }
    field :company_rating, value: ->(record) { record.purchase_order.get_supplier(record.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:rating) if record.purchase_order.rows.present? }
    field :po_date, value: -> (record) { record.purchase_order.metadata['PoDate'].to_date if record.purchase_order.metadata['PoDate'].present? && record.purchase_order.valid_po_date? }, type: 'date'
    field :followup_date, value: -> (record) { record.purchase_order.followup_date }, type: 'date'
    field :expected_dispatch_date, type: 'date'
    field :expected_delivery_date, type: 'date'
    field :actual_delivery_date, type: 'date'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
