class SupplierRfqsIndex < BaseIndex
  statuses = SupplierRfq.statuses
  index_scope SupplierRfq 
    witchcraft!
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: 'integer'
    field :email_sent_at, type: 'date'
    field :status_string, value: -> (record) { record.status.to_s }, analyzer: 'substring'
    field :status, value: -> (record) { statuses[record.status] }
    field :status_key, value: -> (record) { statuses[record.status] }, type: 'integer'
    field :line_items, value: -> (record) { record.inquiry_product_suppliers.map { |ips| ips.inquiry_product.product }.count }, analyzer: 'substring'
    field :supplier_id, value: -> (record) { record.supplier_id }, type: 'integer'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
    field :potential_value, value: -> (record) { record.calculated_total.to_s if record.calculated_total.present? }, type: 'double'
    field :calculated_total, value: -> (record) { record.calculated_total.to_s if record.calculated_total.present? }, analyzer: 'substring'
    field :calculated_total_with_tax, value: -> (record) { record.calculated_total_with_tax.to_s if record.calculated_total_with_tax.present? }, analyzer: 'substring'
  
end
