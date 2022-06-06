# index Po Requests with Elastic search
class PoRequestsIndex < BaseIndex
    PoRequest.statuses
    statuses = PoRequest.statuses
    email_statuses = PoRequest.email_statuses
    define_type PoRequest.all.send(:handled).with_includes do 
        field :id, type: 'integer'
        field :po_request_id, value: -> (record) { record.id }, type: 'integer'
        field :po_request_string, value: -> (record) { record.id.to_s } , analyzer: 'substring'
        field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number } ,type: 'integer'
        field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s }, analyzer: 'substring'
        field :supplier, value: -> (record) { record&.supplier.to_s } , analyzer: 'substring'
        field :customer, value: -> (record) { record&.inquiry&.company.to_s } , analyzer: 'substring'
        field :customer_alias, value: -> (record) { record&.inquiry&.account.to_s }
        field :customer_po_number, value: -> (record) { record&.inquiry&.customer_po_number }
        field :supplier_committed_date, value: -> (record) { record.supplier_committed_date.present? ? record.supplier_committed_date : 'N / A'}
        field :customer_committed_date, value: -> (record) { record.inquiry.customer_committed_date}
        field :buying, value: -> (record) { record.buying_price }
        field :selling, value: -> (record) { record.selling_price }
        field :margin, value: ->(record) { "#{record.po_margin_percentage.to_s} - #{record.po_margin.to_s}" }
        field :status, value: -> (record) { statuses[record.status] }, type: 'integer'
        field :email_status, value: -> (record) { record.purchase_order.try(:has_sent_email_to_supplier?) ?  email_statuses['Supplier PO: Sent to Supplier']: email_statuses['Supplier PO: Not Sent to Supplier'] },type: 'integer'
        field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }, type: 'integer'
        field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'
        field :updated_at,  value: -> (record) { record.last_comment.updated_at if record.last_comment.present? },type: 'date'
        field :created_at, type: 'date'

    end
end