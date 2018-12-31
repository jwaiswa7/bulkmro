class PurchaseOrdersIndex < BaseIndex
  status =  PurchaseOrder.statuses

  define_type PurchaseOrder.all.with_includes do
    field :id

    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }
    field :inquiry, value: -> (record) { record.inquiry.to_s }, analyzer: 'substring'

    field :po_number, value: -> (record) { record.po_number.to_i }, type: 'integer'
    field :po_number_string, value: -> (record) { record.po_number.to_s }, analyzer: 'substring'
    field :po_status, value: -> (record) { record.metadata['PoStatus'].to_i }, type: 'integer'
    field :po_status_string, value: -> (record) { record.status || record.metadata_status  }, analyzer: 'substring'
    field :supplier_id, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).try(:id) if record.rows.present? }
    field :supplier, value: -> (record) { record.get_supplier(record.rows.first.metadata['PopProductId'].to_i).to_s if record.rows.present? }, analyzer: 'substring'
    field :customer_id, value: -> (record) { record.inquiry.company.try(:id) if record.inquiry.company.present? }
    field :customer, value: -> (record) { record.inquiry.company.to_s if record.inquiry.company.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry.outside_sales_owner.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :company_id, value: -> (record) { record.inquiry.company_id if record.inquiry.present? }
    field :po_date, value: -> (record) { record.metadata['PoDate'].to_date.strftime("%d-%b-%Y").to_s if record.metadata['PoDate'].present? }
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end