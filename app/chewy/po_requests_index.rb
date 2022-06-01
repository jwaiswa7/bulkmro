# index Po Requests with Elastic search
class PoRequestsIndex < BaseIndex
    define_type PoRequest.all.send(:handled) do 
        field :request_number, value: -> (record) { record.id }
        field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number }
        field :purchase_order, value: -> (record) { record.id }
        field :supplier, value: -> (record) { record&.supplier.to_s }
        field :customer, value: -> (record) { record&.inquiry&.company.to_s }
        field :customer_alias, value: -> (record) { record&.inquiry&.account.to_s }
        field :customer_po_number, value: -> (record) { record&.inquiry&.customer_po_number }
        field :supplier, value: -> (record) { record.supplier_committed_date.present? ? record.supplier_committed_date : 'N / A'}
        field :customer, value: -> (record) { po_request.inquiry.customer_committed_date}
        field :buying, value: -> (record) { record.buying_price }
        field :selling, value: -> (record) { record.selling_price }
        field :margin, value: ->(record) { "#{record.po_margin_percentage.to_s} - #{record.po_margin.to_s}" }
        field :po_status, value: -> (record) { record.status }
        field :email_status, value: -> (record) { record.has_sent_email_to_supplier }
    end
end


#   def self.fields
#     [:status, :status_string, :subject, :inquiry_number_string, :sales_orders_ids, :sales_invoices_ids, :inside_sales_owner, :outside_sales_owner, :inside_sales_executive, :outside_sales_executive, :procurement_operations, :company, :account, :contact_s, :opportunity_type, :created_by_id, :key_acc_manager]
#   end